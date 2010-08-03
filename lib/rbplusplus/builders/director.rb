module RbPlusPlus
  module Builders

    # This class takes care of the generation of Rice::Director wrapper
    # classes. It's slightly different than other nodes, as it's self.code
    # is the class we're wrapping a director around.
    class DirectorNode < Base

      attr_reader :methods_wrapped

      def initialize(code, parent, class_qualified_name, superclass)
        super(code, parent)

        @class_qualified_name = class_qualified_name
        @methods_wrapped = []
        @superclass = superclass
        @constructors = []

        @class_base_name = class_qualified_name.split("::")[-1]
        @name = "#{@class_base_name}Director"
      end

      def qualified_name
        @name
      end

      def build
        add_child IncludeNode.new(self, "rice/Director.hpp", :global)
        add_child IncludeNode.new(self, "rice/Constructor.hpp", :global)

        # To ensure proper compilation, this director class needs
        # to implement all pure virtual methods found up the
        # inheritance heirarchy of this class. So here, we traverse
        # this list and build the nest of required methods
        wrapped_names = []
        klass = self.code
        while klass.is_a?(RbGCCXML::Class) || klass.is_a?(RbGCCXML::Struct)
          [klass.methods].flatten.each do |method|
            next if do_not_wrap?(method)
            if method.virtual? && !wrapped_names.include?(method.name)
              @methods_wrapped << method
              wrapped_names << method.name

              add_child DirectorMethodNode.new(method, self.parent, self)
            end
          end
          klass = klass.superclass
        end
      end

      def wrap_constructor(constructor)
        @constructors << constructor
      end

      def write_constructor(constructor = nil)
        args = ["Rice::Object self"]
        types = [@name, "Rice::Object"]
        supercall_args = []

        if constructor
          constructor.arguments.each do |arg|
            type = arg.cpp_type.to_cpp
            name = arg.name

            args << "#{type} #{name}"
            types << type
            supercall_args << name
          end
        end

        declarations << "\t\t#{@name}(#{args.join(", ")}) : #{@class_qualified_name}(#{supercall_args.join(", ")}), Rice::Director(self) { }"

        registrations << "\t#{self.parent.rice_variable}.define_director< #{@name} >();"
        registrations << "\t#{self.parent.rice_variable}.define_constructor(Rice::Constructor< #{types.join(", ")} >());"
      end

      def write
        declarations << "class #{@name} : public #{@class_qualified_name}, public Rice::Director  {"
        declarations << "\tpublic:"

        # Handle constructors
        if @constructors.empty?
          write_constructor
        else
          @constructors.each {|c| write_constructor(c) }
        end

        # Each virtual method gets wrapped
        @methods_wrapped.each do |method|

          cpp_name = method.qualified_name.split("::")[-1]
          ruby_name = Inflector.underscore(method.name)
          return_type = method.return_type.to_cpp
          return_call = return_type != "void" ? "return" : ""

          def_arguments = []
          call_arguments = []
          method.arguments.each do |a|
            def_arg = a.value ? " = #{a.value}" : ""
            def_arguments << "#{a.cpp_type.to_cpp} #{a.name}#{def_arg}"
            call_arguments << a.name
          end

          def_arguments = def_arguments.length == 0 ? "" : def_arguments.join(", ")

          reverse = ""
          up_or_raise =
            if method.default_return_value
              reverse = "!"
              "return #{method.default_return_value}"
            else
              if method.purely_virtual?
                "raisePureVirtual()"
              else
                "#{return_call} this->#{method.qualified_name}(#{call_arguments.join(", ")})"
              end
            end

          call_down = "getSelf().call(\"#{ruby_name}\"#{call_arguments.empty? ? "" : ", "}#{call_arguments.map {|a| "to_ruby(#{a})" }.join(", ")})"
          call_down = "return from_ruby< #{return_type} >( #{call_down} )" if return_type != "void"

          const = method.const? ? "const" : ""

          # Write out the virtual method that forwards calls into Ruby
          declarations << ""
          declarations << "\t\tvirtual #{return_type} #{cpp_name}(#{def_arguments}) #{const} {"
          declarations << "\t\t\t#{call_down};"
          declarations << "\t\t}"

          # Write out the wrapper method that gets exposed to Ruby that handles
          # going up the inheritance chain
          declarations << ""
          declarations << "\t\t#{return_type} default_#{cpp_name}(#{def_arguments}) #{const} {"
          declarations << "\t\t\t#{up_or_raise};"
          declarations << "\t\t}"

        end

        declarations << "};"
      end

    end

  end
end

