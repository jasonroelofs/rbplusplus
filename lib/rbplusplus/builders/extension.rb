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
        # Make sure we ignore anything from the :: namespace
        if @code.name != "::"
#          build_modules
          
          build_global_functions
          build_enumerations
#          build_classes
        end

        nodes.flatten!
      end

      def write
        # Let nodes build their code, splitting up code blocks into
        # includes, declarations, and registrations, 
        # then wrap it up in our own template
        registrations.unshift("extern \"C\"", "void Init_#{@name}() {")
        registrations << "}"        

        registrations.flatten!
      end

      private

      # Build up method nodes for the functions to be wrapped
      # in the Kernel (global) namespace for this extension
      def build_global_functions
        @code.functions.each do |func|
          node = GlobalFunctionNode.new(func, self)
          node.build
          nodes << node
        end
      end

      # Wrap up enumerations for this node.
      # Anonymous enumerations are a special case. C++ doesn't
      # see them as a seperate type and instead are just "scoped" constants,
      # so we have to wrap them as such, constants.
      def build_enumerations
        @code.enumerations.each do |enum|
          next if enum.ignored? || enum.moved? || !enum.public? 

          if enum.anonymous?
            # So for each value of this enumeration, 
            # expose it as a constant
            enum.values.each do |value|
              node = ConstNode.new(value, self)
              node.build
              nodes << node
            end
          else
            node = EnumerationNode.new(enum, self)
            node.build
            nodes << node
          end

        end
      end

    end

  end
end
