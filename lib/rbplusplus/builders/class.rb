module RbPlusPlus
  module Builders

    # Handles the generation of Rice code to wrap classes
    class ClassNode < Base
      include ClassHelpers
      include EnumerationHelpers

      def build
        nodes << IncludeNode.new(self, code.file)

        with_enumerations
        with_classes
        with_constructors
        with_constants
        with_variables
        with_methods
      end

      def write
      end

    end

  end
end
