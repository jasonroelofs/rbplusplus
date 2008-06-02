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
        @registered_nodes = []
      end
      
      # adds a register function to the Init or register of this node
      def register_node(node, register_func)
        @registered_nodes << [node, register_func]
      end
      
    private
      
      def nested_level(node, level=0)
        return level if node.is_a? RbGCCXML::Namespace
        return level if node.super_classes.length == 0
        node.super_classes.each do |sup|
          level = nested_level(sup, level+1)
        end
        return level
      end
      
    public
      
      # sorts the registered nodes by hierachy, registering the base classes
      # first.
      #
      # this is necessary for Rice to know about inheritance
      def registered_nodes
        #sort by hierachy
        nodes = @registered_nodes.sort_by do |build, func|
          if build.node.nil?
            0
          else  
            nested_level(build.node)
          end
        end
        
        #collect the sorted members
        nodes.collect do |node, func|
          func
        end
      end
      
      # The name of the header file to include
      # This is the file default, so long as it matches one of the export files
      # If not this returns all exported files.
      #
      # This was added to workaround badly declared namespaces
      def header_files(node)
        file = node.file_name(false)
        return [file] if self.class.sources.include?(file)
        self.class.sources
      end
      
      # Adds the necessary includes in order to compile the specified node
      def add_includes_for(node)
        header_files(node).each do |header|
          includes << "#include \"#{header}\""
        end
      end
      
      # Include any user specified include files
      def add_additional_includes
        self.class.additional_includes.each do |inc|
          includes << "#include \"#{inc}\""
        end
      end
      
      # Set a list of user specified include files
      def self.additional_includes=(addl)
        @@additional_includes = addl
      end
      
      # Get an array of user specified include files
      def self.additional_includes
        @@additional_includes || []
      end
      
      # A list of all the source files.  This is used in order to prevent files 
      # that are not in the list from being included and mucking things up
      def self.sources=(sources)
        @@sources = sources
      end
      
      # Retrieves a list of user specified source files
      def self.sources
        @@sources || []
      end

      # All builders must implement this method
      def build
        raise "Builder needs to implement #build"
      end

      # Builders should use to_s to make finishing touches on the generated
      # code before it gets written out to a file.
      def to_s
        extras = []
        #Weird trailing } needs to be destroyed!!!
        if self.body.flatten[-1].strip == "}"
          extras << self.body.delete_at(-1)
        end
    
        return [
          self.includes.flatten.uniq, 
          "", 
          self.declarations, 
          "", 
          self.body,
          "", 
          self.registered_nodes, 
          extras
        ].flatten.join("\n")
      end

      # Get the full qualified name of the related gccxml node
      def qualified_name
        @node.qualified_name
      end

      # Register all classes
      def build_classes(classes = nil)
        classes ||= [@node.classes, @node.structs].flatten
        classes.each do |klass|
          next if klass.ignored? || klass.moved?
          next unless klass.public?
          builder = ClassBuilder.new(self, klass)
          builder.build
          builders << builder
        end
      end

      # Find and wrap up all enumerations
      def build_enumerations
        @node.enumerations.each do |enum|
          builder = EnumerationBuilder.new(self, enum)
          builder.build
          builders << builder
        end
      end

      # Compatibility with Rice 1.0.1's explicit self requirement, build a quick
      # wrapper that includes a self and discards it, forwarding the call as needed.
      #
      # Returns: the name of the wrapper function
      def build_function_wrapper(function)
        return if function.ignored? || function.moved?
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



      # Compatibility with Rice 1.0.1's method overloading issues. Build a quick
      # wrapper that includes a self, forwarding the call as needed.
      #
      # Returns: the name of the wrapper function
      def build_method_wrapper(cls, method, i)
        return if method.ignored? || method.moved?
        wrapper_func = "wrap_#{method.qualified_name.gsub(/::/, "_")}_#{i}"
        proto_string = ["#{cls.qualified_name} *self"]
        call_string = []
        method.arguments.map{|arg| [arg.cpp_type.to_s(true), arg.name]}.each do |parts|
          type = parts[0]
          name = parts[1]
          proto_string << "#{type} #{name}"
          call_string << "#{name}"
        end
        
        proto_string = proto_string.join(",")
        call_string = call_string.join(",")
        return_type = method.return_type.to_s(true)
        returns = "" if return_type == "void"
        returns ||= "return"
        
        declarations << "#{return_type} #{wrapper_func}(#{proto_string}) {"
        declarations << "\t#{returns} self->#{method.qualified_name}(#{call_string});"
        declarations << "}"
        
        wrapper_func
      end
    end
  end
end
