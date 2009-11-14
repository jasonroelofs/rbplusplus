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

      attr_reader :additional_includes

      def initialize(name, code, modules)
        self.name = name
        self.modules = modules

        @additional_includes = []

        super(code, nil)
      end

      def qualified_name
        name
      end

      def add_includes(includes)
        @additional_includes << includes
        includes.each do |inc|
          add_child IncludeNode.new(self, inc)
        end
      end

      def build
        super
        self.rice_variable = nil
        self.rice_variable_type = nil
      end

      def write
        # Let nodes build their code, splitting up code blocks into
        # includes, declarations, and registrations,
        # then wrap it up in our own template
        registrations << "extern \"C\""
        registrations << "void Init_#{@name}() {"
        registrations << "RUBY_TRY {"
      end

      private

      def with_module_functions
        @code.functions.each do |func|
          next if do_not_wrap?(func)
          add_child GlobalFunctionNode.new(func, self)
        end
      end

    end

  end
end
