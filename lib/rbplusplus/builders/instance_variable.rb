module RbPlusPlus
  module Builders

    # Wrap up a class instance variable
    class InstanceVariableNode < Base

      def build
      end

      def write
        ruby_name = Inflector.underscore(code.name)
        parent_name = parent.code.qualified_name.as_variable

        # Setter, only if it isn't const
        if !code.cpp_type.const?
          method_name = "wrap_#{parent_name}_#{code.name}_set"
          declarations << "void #{method_name}(#{parent.code.qualified_name}* self, #{code.cpp_type.to_cpp} val) {"
          declarations << "\tself->#{code.name} = val;"
          declarations << "}"

          registrations << "\t#{parent.rice_variable}.define_method(\"#{ruby_name}=\", &#{method_name});"
        end

        # Getter
        method_name = "wrap_#{parent_name}_#{code.name}_get"
        declarations << "#{code.cpp_type.to_cpp} #{method_name}(#{parent.code.qualified_name}* self) {"
        declarations << "\treturn self->#{code.name};"
        declarations << "}"

        registrations << "\t#{parent.rice_variable}.define_method(\"#{ruby_name}\", &#{method_name});"
      end

    end

  end
end
