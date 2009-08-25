module RbPlusPlus
  module Builders

    # Extension node.
    # There is only ever one of these in a project as this is
    # the top level node for building a Ruby extension.
    #
    # Extensions are effectively Modules with some slightly different
    # symantics, in that they expose to Kernel and have slightly
    # different function handling and code generation.
    class ExtensionNode < ModuleNode

      def initialize(name, code, modules)
        super(name, code, modules, nil)
      end

      def add_includes(includes)
        includes.each do |inc|
          nodes << IncludeNode.new(self, inc)
        end
      end

      def build
        super
        self.rice_variable_type = nil
        self.rice_variable = nil
      end

      def write
        # Let nodes build their code, splitting up code blocks into
        # includes, declarations, and registrations,
        # then wrap it up in our own template
        registrations << "extern \"C\""
        registrations << "void Init_#{@name}() {"
      end

      private

      def build_module_functions
        @code.functions.each do |func|
          node = GlobalFunctionNode.new(func, self)
          node.build
          nodes << node
        end
      end

    end

  end
end
