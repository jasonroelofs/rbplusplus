module RbPlusPlus
  module Builders

    # Handles code generation dealing with user-defined modules.
    class ModuleNode < Base
      include ModuleHelpers
      include EnumerationHelpers
      include ClassHelpers

      # Has a name
      attr_accessor :name

      # Link to the Module as defined by the user
      attr_accessor :module

      # And needs to specially handle any other nexted modules
      attr_accessor :modules

      def initialize(node, name, code, modules, parent = nil)
        super(code, parent)

        @module = node
        @name = name
        @modules = modules
      end

      def build
        with_modules

        nodes << IncludeNode.new(self, "rice/Module.hpp", :system)

        # Make sure we ignore anything from the :: namespace
        if self.code && self.code.name != "::"
          with_module_functions
          with_enumerations
          with_classes
        end

        nodes.flatten!
      end

      def write
        self.rice_variable_type = "Rice::Module"
        self.rice_variable = "rb_m#{as_variable(@module.qualified_name)}"

        registrations << "#{rice_variable_type} #{rice_variable} = " \
                         "Rice::define_module(\"#{@name}\");"
      end
    end

  end
end
