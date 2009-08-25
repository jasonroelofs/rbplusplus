module RbPlusPlus
  module Builders

    # Base class for all code generation nodes
    #
    # A Node is simply a handler for one complete statement or block of C++ code.
    #
    # The code generation system for Rb++ is a two step process.
    # We first, starting with an ExtensionNode, build up an internal representation
    # of the resulting code, setting up all the code nodes required for proper
    # wrapping of the library. 
    #
    # Once that's in place, then we run through the tree, actually generating
    # the C++ wrapper code.
    class Base

      # List of includes for this node
      attr_accessor :includes

      # List of declaration nodes for this node
      attr_accessor :declarations

      # List of registeration nodes for this node
      attr_accessor :registrations

      # Link to the parent node of this node
      attr_accessor :parent

      # Link to the underlying rbgccxml node this node is writing code for
      attr_accessor :code

      # List of children nodes
      attr_accessor :nodes

      # The Rice variable name for this node
      attr_accessor :rice_variable

      # The type of the rice_variable
      attr_accessor :rice_variable_type

      def initialize(code, parent = nil) 
        @code = code
        @parent = parent
        @includes = []
        @declarations = []
        @registrations = []
        @nodes = []
      end

      # Does this builder node have child nodes?
      def has_children?
        @nodes && !@nodes.empty?
      end

      # Trigger the construction of the internal representation of a given node.
      # All nodes must implement this.
      def build
        raise "Nodes must implement #build"
      end

      # After #build has run, this then triggers the actual generation of the C++
      # code and returns the final string. 
      # All nodes must implement this.
      def write
        raise "Nodes must implement #write"
      end

      protected

      # Get the code prefix using parent's rice variable, or just
      # return the default that's passed in.
      # 
      # @See EnumerationNode for an example of usage
      def parent_prefix_or(default)
        puts "Parent of #{self} is #{self.parent}"
        self.parent.rice_variable ? "#{parent.rice_variable}." : default
      end

      # Wrap up enumerations for this node.
      # Anonymous enumerations are a special case. C++ doesn't
      # see them as a seperate type and instead are just "scoped" constants,
      # so we have to wrap them as such, constants.
      def build_enumerations
        self.code.enumerations.each do |enum|
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
