module RbPlusPlus
  module Builders

    # Top class for all source generation classes. A builder has three seperate
    # code "parts" to fill up for the source writer:
    #
    #   includes
    #   declarations
    #   body
    #
    # includes:
    #   The list of #include's needed for this builder's code to compile
    #
    # declarations:
    #   Any extra required functions or class declarations that will be defined
    #   outside of the main body of the code
    #
    # body:
    #   The body is the code that will go in the main control function
    #   of the file. For extensions, it's Init_extension_name() { [body] }.
    #   For classes it's usually a register_ClassName() { [body] }, and so on.
    #
    # All builders can access their parent and add pieces of code to any of these
    # three parts
    #
    class Base

      attr_reader :name, :node
      
      # Any given builder has a list of sub-builders of any type
      attr_accessor :builders

      # Builders need to constcuct the following code parts
      #
      # The list of includes this builder needs
      attr_accessor :includes
      # The list of declarations to add
      attr_accessor :declarations
      # The body code
      attr_accessor :body

      # Link to the parent builder who created said builder
      attr_accessor :parent

      # The name of the C++ variable related to this builder.
      attr_accessor :rice_variable
      attr_accessor :rice_variable_type

      # Create a new builder.
      def initialize(name, parser)
        @name = name
        @node = parser
        @builders = []
        @includes = []
        @declarations = []
        @body = []
      end

      # All builders must implement this method
      def build
        raise "Builder needs to implement #build"
      end

      # Builders should use to_s to make finishing touches on the generated
      # code before it gets written out to a file.
      def to_s
        [self.includes.uniq, "", self.declarations, "", self.body].flatten.join("\n")
      end

      # Get the full qualified name of the related gccxml node
      def qualified_name
        @node.qualified_name
      end

      # Register all classes
      def build_classes
        @node.classes.each do |klass|
          builder = ClassBuilder.new(self, klass)
          builder.build
          builders << builder
        end
      end
    end
  end
end
