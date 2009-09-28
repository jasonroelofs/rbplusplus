module RbPlusPlus
  module Builders

    # Wrap up a static method on a class
    class StaticMethodNode < MethodBase

      def build
        self.rice_method = "define_singleton_method"
      end

    end

  end
end
