module RbPlusPlus
  module Builders

    # Handles code generation dealing with user-defined modules.
    class ModuleNode < Base

      # Has a name
      attr_accessor :name

      # And needs to specially handle any other nexted modules
      attr_accessor :modules

      def initialize(name, code, modules, parent = nil)
        super(code, parent)

        @name = name
        @modules = modules
      end

      def build
        self.rice_variable_type = "Rice::Module"
        self.rice_variable = "rb_m#{@name}"

        # Make sure we ignore anything from the :: namespace
        if self.code.name != "::"
          build_modules
          build_module_functions
          build_enumerations
#          build_classes
        end

        nodes.flatten!
      end

      def write
        registrations << "#{rice_variable_type} #{rice_variable} = " \
                         "Rice::define_module(\"#{@name}\");"
      end

      protected

      # Build up any user-defined modules for this node
      def build_modules
        self.modules.each do |m|
          node = ModuleNode.new(m.name, m.node, m.modules, self)
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
