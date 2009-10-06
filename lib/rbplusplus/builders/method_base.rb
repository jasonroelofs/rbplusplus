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
          declarations << "#{funcall};"
        else
          declarations << "return from_ruby<#{return_type} >(#{funcall});"
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
        declarations << "\t#{callee}(&#{proxy_method_name});"
        declarations << "\treturn Qnil;"
        declarations << "}"

        registrations << "#{self.prefix}#{self.rice_method}(\"#{@ruby_name + self.suffix}\", &#{wrapper_func});"
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
          default_arguments << "Rice::Arg(\"#{arg.name}\")#{arg.value ? " = (#{arg.cpp_type.to_cpp})#{arg.value}" : "" }"
        end

        return_type = find_typedef_for(self.code.return_type).to_cpp

        def_args = default_arguments.any? ? ", (#{default_arguments.join(", ")})" : ""

        registrations << "{"

        registrations << "typedef #{return_type} ( #{method_ref} )( #{arguments.join(", ")} );"
        registrations << "#{self.prefix}#{self.rice_method}(\"#{@ruby_name + self.suffix}\", " +
                          "#{usage_ref}( &#{code.qualified_name} )#{def_args});"

        registrations << "}"
      end

    end

  end
end
