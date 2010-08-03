module RbPlusPlus
  module Builders

    class ImplicitCasterNode < Base

      def initialize(constructor, parent)
        super(constructor, parent)

        @to = parent.code.qualified_name
        @from = constructor.arguments[0].cpp_type.base_type.qualified_name
      end

      def build
      end

      def write
        if @from != @to
          registrations << "\tRice::define_implicit_cast< #{@from}, #{@to} >();"
        end
      end
    end

  end
end
