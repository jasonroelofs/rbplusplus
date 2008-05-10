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
      def initialize(name, sources, parser)
        @name = name
        @node = parser
        @builders = []
        @includes = []
        @declarations = []
        @body = []
        @sources = sources
      end
      
      def header_files(node)
        return [node.file_name(false)] if @sources.include?(node.file_name(false))
        @sources
      end
      
      def add_includes_for(node)
        header_files(node).each do |header|
          includes << "#include \"#{header}\""
        end
      end

      # All builders must implement this method
      def build
        raise "Builder needs to implement #build"
      end

      # Builders should use to_s to make finishing touches on the generated
      # code before it gets written out to a file.
      def to_s
        [self.includes.flatten.uniq, "", self.declarations, "", self.body].flatten.join("\n")
      end

      # Get the full qualified name of the related gccxml node
      def qualified_name
        @node.qualified_name
      end

      # Register all classes
      def build_classes(classes = nil)
        classes ||= @node.classes
        classes.each do |klass|
          next if klass.ignored?
          builder = ClassBuilder.new(self, @sources, klass)
          builder.build
          builders << builder
        end
      end

      # Compatibility with Rice 1.0.1's explicit self requirement, build a quick
      # wrapper that includes a self and discards it, forwarding the call as needed.
      #
      # Returns: the name of the wrapper function
      def build_function_wrapper(function)
        return if function.ignored?
        wrapper_func = "wrap_#{function.qualified_name.gsub(/::/, "_")}"

        proto_string = ["Rice::Object self"]
        call_string = []

        function.arguments.map{|arg| [arg.cpp_type.name, arg.name]}.each do |parts|
          type = parts[0]
          name = parts[1]
          proto_string << "#{type} #{name}"
          call_string << "#{name}"
        end

        proto_string = proto_string.join(",")
        call_string = call_string.join(",")
        return_type = function.return_type.name
        returns = "" if return_type == "void"
        returns ||= "return"

        declarations << "#{return_type} #{wrapper_func}(#{proto_string}) {"
        declarations << "\t#{returns} #{function.qualified_name}(#{call_string});"
        declarations << "}"

        wrapper_func
      end

    end
  end
end
