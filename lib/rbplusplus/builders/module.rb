module RbPlusPlus
  module Builders

    # Handles code generation dealing with user-defined modules.
    class ModuleNode < Base
      include ModuleHelpers
      include EnumerationHelpers
      include ClassHelpers

      # Has a name
      attr_accessor :name

      # And needs to specially handle any other nexted modules
      attr_accessor :modules

      # Node is the RbModule object, it proxies any unknown calls
      # off to it's internal Node object
      def initialize(code, parent = nil)
        super

        @name ||= code.name
        @modules ||= code.modules
      end

      def qualified_name
        self.code.qualified_name
      end

      def build
        with_modules

        add_child IncludeNode.new(self, "rice/Module.hpp", :system)

        # Make sure we ignore anything from the :: namespace
        if self.code && self.code.name != "::"
          with_module_functions
          with_enumerations
          with_classes
        end

        nodes.flatten!

        self.rice_variable_type = "Rice::Module"
        self.rice_variable = "rb_m#{self.qualified_name.as_variable}"
      end

      def write
        prefix = "\t#{rice_variable_type} #{rice_variable} = "

        if parent.rice_variable
          registrations << "#{prefix} Rice::define_module_under(#{parent.rice_variable}, \"#{@name}\");"
        else
          registrations << "#{prefix} Rice::define_module(\"#{@name}\");"
        end
      end
    end

  end
end
