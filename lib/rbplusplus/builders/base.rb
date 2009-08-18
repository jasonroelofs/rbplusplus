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

      def initialize(code) 
        @code = code
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

    end

  end
end
