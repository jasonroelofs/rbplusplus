module RbPlusPlus
  module Builders

    # Base class for any type of method or function handling
    class MethodBase < Base

      attr_accessor :prefix, :rice_method, :suffix

      def initialize(code, parent = nil)
        super

        # Overload checks:
        #  - If we're the only one, no overload required
        #  - If we're one of many w/ the same name:
        #     - Find out which in the list we are
        #     - Add the number to ruby_name, unless user has renamed
        #     - Build typedef of the method and use it in the exposure
        found = [code.parent.methods(code.name)].flatten
        if found.length > 1 && !code.renamed?
          num = found.index(code)
          self.suffix = "_#{num}"
        end
      end

      # Wrap up this method making sure that overloads
      # are properly typedef'd to keep from compiler error from unresolvable types
      #
      # Thanks to Py++ for the appropriate C++ syntax for this.
      def write
        @ruby_name = Inflector.underscore(code.name)

        self.prefix ||= "#{self.parent.rice_variable}."
        self.suffix ||= ""

        if self.code.arguments.size == 1 && (fp = self.code.arguments[0].cpp_type.base_type).is_a?(RbGCCXML::FunctionType)
          wrap_with_function_pointer(fp)
        else
          wrap_normal_method
        end
      end

      # This method should return the full C++ path to the method you're exposing
      def code_path
        self.code.qualified_name
      end

      protected

      # Handling methods that take function pointers takes a lot of extra custom code.
      #  - Need a method that acts as the proxy between C and the Ruby proc
      #  - Need a method that gets wrapped into Ruby to handle type conversions
      #
      def wrap_with_function_pointer(func_pointer)
        Logger.info "Building callback wrapper for #{self.code.qualified_name}"

        base_name = self.code.qualified_name.as_variable
        return_type = func_pointer.return_type.to_cpp
        proxy_method_name = "do_yield_on_#{base_name}"

        callback_arguments = []
        callback_values = [func_pointer.arguments.length]

        func_pointer.arguments.each_with_index do |arg, i|
          callback_arguments << "#{arg.to_cpp} arg#{i}"
          callback_values << "to_ruby(arg#{i}).value()"
        end

        # Build the method that acts as the Proc -> C func pointer proxy (the callback)
        block_var_name = "_block_for_#{base_name}"
        declarations << "VALUE #{block_var_name};"
        declarations << "#{return_type} #{proxy_method_name}(#{callback_arguments.join(", ")}) {"

        funcall = "rb_funcall(#{block_var_name}, rb_intern(\"call\"), #{callback_values.join(", ")})"
        if return_type == "void"
          declarations << "\t#{funcall};"
        else
          declarations << "\treturn from_ruby<#{return_type} >(#{funcall});"
        end

        declarations << "}"

        if self.parent.is_a?(ClassNode)
          arg = "#{self.parent.qualified_name} *self"
          callee = "self->#{self.code.qualified_name}"
        else
          arg = ""
          callee = "#{self.code.qualified_name}"
        end

        wrapper_func = "wrap_for_callback_#{base_name}"

        # Build the wrapper method that gets exposed to Ruby
        declarations << "VALUE #{wrapper_func}(#{arg}) {"
        declarations << "\t#{block_var_name} = rb_block_proc();"
        declarations << "\trb_gc_register_address(&#{block_var_name});"
        declarations << "\t#{callee}(&#{proxy_method_name});"
        declarations << "\treturn Qnil;"
        declarations << "}"

        registrations << "\t#{self.prefix}#{self.rice_method}(\"#{@ruby_name + self.suffix}\", &#{wrapper_func});"
      end

      def wrap_normal_method
        parts = "#{self.qualified_name}".split("::")
        usage_ref = "#{parts[-1]}_func_type"

        if self.code.static? || self.code.as_instance_method?
          method_ref = "*#{usage_ref}"
        else
          method_ref = [parts[0..-2], "*#{usage_ref}"].flatten.join("::")
        end

        default_arguments = []
        arguments = []

        self.code.arguments.each do |arg|
          arguments << arg.to_cpp

          default_value =
            if arg.value
              if (base_type = arg.cpp_type.base_type).is_a?(RbGCCXML::Enumeration)
                " = #{fix_enumeration_value(base_type, arg.value)}"
              elsif base_type.is_a?(RbGCCXML::FundamentalType)
                " = (#{arg.cpp_type.base_type.to_cpp})(#{arg.value})"
              else
                " = (#{arg.value})"
              end
            else
              ""
            end

          default_arguments << "Rice::Arg(\"#{arg.name}\")#{default_value}"
        end

        return_type = find_typedef_for(self.code.return_type).to_cpp

        def_args = default_arguments.any? ? ", (#{default_arguments.join(", ")})" : ""

        const = self.code.const? ? " const" : ""

        registrations << ""
        registrations << "\t{"

        registrations << "\t\ttypedef #{return_type} ( #{method_ref} )( #{arguments.join(", ")} )#{const};"
        registrations << "\t\t#{self.prefix}#{self.rice_method}(\"#{@ruby_name + self.suffix}\", " +
                          "#{usage_ref}( &#{code_path} )#{def_args});"

        registrations << "\t}"
      end

      # See http://www.gccxml.org/Bug/view.php?id=9234
      #
      # Basically due to inconsistencies within gcc, GCC-XML parses default arguments
      # with having enumeration values exactly as they are in the code. This means
      # that if the C++ doesn't fully namespace the enumeration, extension compilation
      # will fail because g++ can't find the enumeration.
      #
      # We work around this by checking if the argument is an Enumeration (above), then
      # grabbing the appropriate EnumValue and printing it out.
      #
      # Of course, there could be times we don't want to do this and just use the actual
      # default value. See default_arguments_test and headers/default_arguments.h
      # for an example.
      def fix_enumeration_value(enum, default_value)
        enum_values = [enum.values].flatten
        found =
          enum_values.select do |enum_value|
            enum_value.name == default_value
          end.first

        found ? found.qualified_name : default_value
      end

    end

  end
end
