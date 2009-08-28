module RbPlusPlus
  module Builders

    # Expose a global function
    class GlobalFunctionNode < Base

      def build
        add_child IncludeNode.new(self, "rice/global_function.hpp", :system)
        add_child IncludeNode.new(self, code.file)
      end

      def write
        ruby_name = "#{Inflector.underscore(code.name)}"
        registrations << 'Rice::define_global_function("%s", &%s);' % [ruby_name, code.qualified_name]
      end

    end

  end
end
