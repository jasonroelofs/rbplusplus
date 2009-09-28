module RbPlusPlus
  module Builders
    module ModuleHelpers

      # Build up any user-defined modules for this node
      def with_modules
        self.modules.each do |mod|
          add_child ModuleNode.new(mod, self)
        end
      end

      # Expose a function in this module
      def with_module_functions
        [self.code.functions].flatten.each do |func|
          next if do_not_wrap?(func)
          add_child ModuleFunctionNode.new(func, self)
        end
      end

    end
  end
end
