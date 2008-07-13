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
      @modules << RbModule.new(name, @parser, &block)
    end

  end
end
