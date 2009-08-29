module RbPlusPlus
  module Builders

    # Wrap up a static method on a class
    class StaticMethodNode < Base

      def build
      end

      def write
        ruby_name = Inflector.underscore(code.name)
        registrations << "#{parent.rice_variable}.define_singleton_method(\"#{ruby_name}\", &#{code.qualified_name});"
      end

    end

  end
end
