module RbPlusPlus
  module Builders
    module ClassHelpers

      # Build up any classes under this module
      def with_classes
        self.code.classes.each do |klass|
          node = ClassNode.new(klass, self)
          node.build
          nodes << node
        end
      end

      def with_constructors
      end

      def with_constants
      end

      def with_variables
      end

      def with_methods
      end

    end
  end
end
