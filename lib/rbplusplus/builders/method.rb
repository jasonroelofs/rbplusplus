module RbPlusPlus
  module Builders

    # Wrap up an indivitual method
    class MethodNode < MethodBase

      def build
        self.rice_method = "define_method"
      end

    end

  end
end
