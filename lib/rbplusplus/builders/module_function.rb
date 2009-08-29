module RbPlusPlus
  module Builders

    # Wrap up a method on a Module as a module_function
    class ModuleFunctionNode < Base

      def build
        add_child IncludeNode.new(self, code.file)
      end

      def write
        ruby_name = Inflector.underscore(code.name)
        registrations << "#{parent.rice_variable}.define_module_function(\"#{ruby_name}\", &#{code.qualified_name});"
      end

    end

  end
end
