module RbPlusPlus
  module Builders

    # Expose a global function
    class GlobalFunctionNode < Base

      def initialize(parent, code)
        super(code)
        @parent = parent
      end

      def build
      end

      def write
      end

    end

  end
end
