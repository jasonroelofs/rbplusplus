module RbPlusPlus
  module Builders

    # This class takes in all classes to be wrapped and builds
    # the top-level extension Init code
    class ExtensionBuilder < Base
      
      # Need to be given the list of modules as they are a special case
      attr_accessor :modules

      def build
        includes << "#include <rice/global_function.hpp>"

        body << "extern \"C\""
        body << "void Init_#{@name}() {"

        # Explicitly ignore anything from the :: namespace
        if @node.name != "::"
          @node.functions.each do |func|
            includes << "#include \"#{func.file_name(false)}\""
            wrapper_name = build_function_wrapper(func)

            if func.return_type.const?
              TypesManager.build_const_converter(func.return_type)
            end

            body << "\tdefine_global_function(\"#{Inflector.underscore(func.name)}\", &#{wrapper_name});"
          end

          build_classes
        end

        build_modules
      end

      def build_modules
        @modules.each do |mod|
          builder = ModuleBuilder.new(self, mod)
          builder.build
          builders << builder
        end
      end

      # Finish up the required code before doing final output
      def to_s
        body << "}"

        super
      end
    end
  end
end
