module RbPlusPlus
  module Builders

    # Extension node.
    # There is only ever one of these in a project as this is
    # the top level node for building a Ruby extension. 
    class ExtensionNode < Base

      attr_accessor :name

      def initialize(name, code, modules)
        super(code)

        @modules = modules
        @name = name 
      end

      def build
        # Top-level Includes
        nodes << IncludeNode.new(self, "rice/global_function.hpp", :system)

        # Make sure we ignore anything from the :: namespace
        if @code.name != "::"
          # Top-level methods
          nodes << build_global_functions

          # Enumerations
          nodes << build_enumerations
          
          # Classes
          nodes << build_classes
          
          # Modules
          nodes << build_modules
        end
      end

      def write
        # Let nodes build their code, splitting up code blocks into
        # includes, declarations, and registrations, 
        # then wrap it up in our own template
      end

      private

      # Build up method nodes for the functions to be wrapped
      # in the Kernel (global) namespace for this extension
      def global_functions
        @code.functions.each do |func|
          node = GlobalFunctionNode.new(self, func)
          node.build
          nodes << node
        end
      end

    end

  end
end
