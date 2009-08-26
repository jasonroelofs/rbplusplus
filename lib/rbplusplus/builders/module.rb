module RbPlusPlus
  module Builders

    # Handles code generation dealing with user-defined modules.
    class ModuleNode < Base

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
        build_modules

        nodes << IncludeNode.new(self, "rice/Module.hpp", :system)

        # Make sure we ignore anything from the :: namespace
        if self.code && self.code.name != "::"
          build_module_functions
          build_enumerations
#          build_classes
        end

        nodes.flatten!
      end

      def write
        self.rice_variable_type = "Rice::Module"
        self.rice_variable = "rb_m#{@module.qualified_name.gsub(/::/, "_")}"

        registrations << "#{rice_variable_type} #{rice_variable} = " \
                         "Rice::define_module(\"#{@name}\");"
      end

      protected

      # Build up any user-defined modules for this node
      def build_modules
        self.modules.each do |m|
          node = ModuleNode.new(m, m.name, m.node, m.modules, self)
          node.build
          nodes << node
        end
      end

      # Expose a function in this module
      def build_module_functions
      end

    end

  end
end
