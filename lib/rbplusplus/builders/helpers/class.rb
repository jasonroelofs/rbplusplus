module RbPlusPlus
  module Builders
    module ClassHelpers

      # Build up any classes under this module
      def with_classes
        self.code.classes.each do |klass|
          next if do_not_wrap?(klass)
          add_child ClassNode.new(klass, self)
        end
      end

      def with_constructors
#        self.code.constructors.find(:access => :public).each do |constructor|
#          next if do_not_wrap?(constructor)
#          add_child ConstructorNode.new(constructor, self)
#        end
      end

      def with_constants
        self.code.constants.find(:access => :public).each do |const|
          next if do_not_wrap?(const)
          add_child ConstNode.new(const, self)
        end
      end

      def with_variables
      end

      def with_methods
      end

    end
  end
end
