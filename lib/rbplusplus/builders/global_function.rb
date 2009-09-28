module RbPlusPlus
  module Builders

    # Expose a global function
    class GlobalFunctionNode < MethodBase

      def build
        add_child IncludeNode.new(self, "rice/global_function.hpp", :system)
        add_child IncludeNode.new(self, code.file)

        self.prefix = "Rice::"
        self.rice_method = "define_global_function"
      end

    end

  end
end
