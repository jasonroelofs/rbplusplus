module RbPlusPlus
  module Builders

    # Wrap up a class instance variable
    class InstanceVariableNode < Base

      def build
      end

      def write
        ruby_name = Inflector.underscore(code.name)

        # Setter, only if it isn't const
        if !code.cpp_type.const?
          method_name = "wrap_#{as_variable(parent.code.qualified_name)}_#{code.name}_set"
          declarations << "void #{method_name}(#{parent.code.qualified_name}* self, #{code.cpp_type.base_type.qualified_name} val) {"
          declarations << "self->#{code.name} = val;"
          declarations << "}"

          registrations << "#{parent.rice_variable}.define_method(\"#{ruby_name}=\", &#{method_name});"
        end

        # Getter
        method_name = "wrap_#{as_variable(parent.code.qualified_name)}_#{code.name}_get"
        declarations << "#{code.cpp_type.base_type.qualified_name} #{method_name}(#{parent.code.qualified_name}* self) {"
        declarations << "return self->#{code.name};"
        declarations << "}"

        registrations << "#{parent.rice_variable}.define_method(\"#{ruby_name}\", &#{method_name});"
      end

    end

  end
end
