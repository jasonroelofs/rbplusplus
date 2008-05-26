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
        [self.includes.flatten.uniq, "", self.declarations, "", self.body].flatten.join("\n")
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

      # Rice doesn't automatically handle all to_ / from_ruby conversions for a given type.
      # A common construct is the +const Type&+ variable, which we need to manually handle.
      def build_const_converter(type)
        full_name = type.base_type.qualified_name
        @@const_wrapped ||= []

        # Only wrap once
        # TODO cleaner way of doing this
        return if @@const_wrapped.include?(full_name)

        @@const_wrapped << full_name
        declarations << "template<>"
        declarations << "Rice::Object to_ruby<#{full_name}>(#{full_name} const & a) {"
        declarations << "\treturn Rice::Data_Object<#{full_name}>((#{full_name} *)&a, Rice::Data_Type<#{full_name}>::klass(), 0, 0);"
        declarations << "}"
      end

      # Compatibility with Rice 1.0.1's explicit self requirement, build a quick
      # wrapper that includes a self and discards it, forwarding the call as needed.
      #
      # Returns: the name of the wrapper function
      def build_function_wrapper(function)
        wrapper_func = "wrap_#{function.qualified_name.gsub(/::/, "_")}"

        proto_string = ["Rice::Object self"]
        call_string = []

        function.arguments.map{|arg| [arg.cpp_type.to_s(true), arg.name]}.each do |parts|
          type = parts[0]
          name = parts[1]
          proto_string << "#{type} #{name}"
          call_string << "#{name}"
        end

        proto_string = proto_string.join(",")
        call_string = call_string.join(",")
        return_type = function.return_type.to_s(true)
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
