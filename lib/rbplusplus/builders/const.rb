module RbPlusPlus
  module Builders

    # Expose a const value
    class ConstNode < Base

      def build
        nodes << IncludeNode.new(self, code.file)
      end

      def write
        registrations << 'Rice::Module(rb_mKernel).const_set("%s", to_ruby((int)%s));' %
                            [code.name, code.qualified_name]
      end

    end

  end
end

