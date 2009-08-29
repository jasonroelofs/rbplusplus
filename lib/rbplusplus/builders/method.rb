module RbPlusPlus
  module Builders

    # Wrap up an indivitual method
    class MethodNode < Base

      def build
      end

      def write
        ruby_name = Inflector.underscore(code.name)
        registrations << "#{parent.rice_variable}.define_method(\"#{ruby_name}\", &#{code.qualified_name});"
      end

    end

  end
end
