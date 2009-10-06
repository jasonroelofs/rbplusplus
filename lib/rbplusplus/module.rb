module RbPlusPlus
  # Class representation of a ruby Module to be exposed in the extension.
  # A Module acts much in the same way as Extension in that it can contain
  # classes, functions, enumerations, etc. 
  class RbModule

    # Modules can be nested
    attr_accessor :modules

    # Modules have a name
    attr_accessor :name

    # Access to the underlying RbGCCXML parser
    attr_reader :node

    # Parent module if this is nested
    attr_accessor :parent

    # Registers a new module definition for this extension.
    # Use Extension#module or RbModule#module instead
    # of creating an instance of this class directly
    #
    # The block parameter is optional, you can also 
    # grab the reference of the Module and work with
    # it as you want:
    #
    #   module "Name" do |m|
    #     ...
    #   end
    #   
    # or
    #
    #   m = module "Name"
    #   ...
    #
    # Unlike Extension#new, no special processing is done
    # in the block version, it's just there for convenience.
    def initialize(name, parser, &block)
      @name = name
      @parser = parser
      @modules = []
      @wrapped_functions = []
      @wrapped_classes = []
      @wrapped_structs = []

      block.call(self) if block
    end

    # Specify a C++ namespace from which the contained code will
    # be wrapped and exposed to Ruby under this Module.
    #
    # Also see Extension#namespace
    def namespace(name)
      @node = @parser.namespaces.find(:all, :name => name)
    end

    # Register another module to be defined inside of
    # this module. Acts the same as Extension#module.
    def module(name, &block)
      m = RbModule.new(name, @parser, &block)
      m.parent = self
      @modules << m
    end

    # Add an RbGCCXML::Node to this module. This Node can be a
    # Function, Class or Struct and will get wrapped accordingly
    def includes(node)
      if node.is_a?(RbGCCXML::Function)
        @wrapped_functions << node
      elsif node.is_a?(RbGCCXML::Class)
        @wrapped_classes << node
      elsif node.is_a?(RbGCCXML::Struct)
        @wrapped_structs << node
      else
        raise "Cannot use #{self.class}#includes for type '#{node.class}'"
      end

      node.moved_to = self
    end

    # Make sure to add to the node.functions any functions specifically
    # given to this module
    def functions(*args)
      [node ? node.functions(*args) : [], @wrapped_functions].flatten
    end

    # As with #functions, add to node.classes any classes / structs that
    # have been explicitly given to this module.
    def classes(*args)
      [node ? node.classes(*args) : [], @wrapped_classes].flatten
    end

    # See #clases and #functions
    def structs(*args)
      [node ? node.structs(*args) : [], @wrapped_structs].flatten
    end

    def enumerations(*args)
      node ? node.enumerations(*args) : []
    end

    # Get the fully nested name of this module
    def qualified_name
      if parent
        "#{parent.qualified_name}::#{self.name}"
      else
        self.name
      end
    end

  end
end
