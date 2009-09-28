module RbPlusPlus
  module Builders

    # Wrap up a method on a Module as a module_function
    class ModuleFunctionNode < MethodBase

      def build
        add_child IncludeNode.new(self, code.file)

        self.rice_method = "define_module_function"
      end

    end

  end
end
