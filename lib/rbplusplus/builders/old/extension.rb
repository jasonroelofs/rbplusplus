module RbPlusPlus
  module Builders

    # This class takes in all classes to be wrapped and builds
    # the top-level extension Init code
    class ExtensionBuilder < Base
      
      # Need to be given the list of modules as they are a special case
      attr_accessor :modules

      def build
        includes << "#include <rice/global_function.hpp>"

        add_additional_includes

        body << "extern \"C\""
        body << "void Init_#{@name}() {"

        # Explicitly ignore anything from the :: namespace
        if @node.name != "::"
        
          #Build a hash table to handle overloaded functions
          func_hash = {}
          @node.functions.each do |func|
            next if func.ignored? || func.moved?
            
            func_hash[func.name] ||= []
            func_hash[func.name] << func
          end

          #Iterate through the hash table to handle overloaded functions
          func_hash.each do |key, funcs|
            funcs.each_with_index do |func, i|
              add_includes_for func
              
              #append _#{i} to overloaded methods
              #this needs to be done in both the wrapper function and the ruby function
              func_append = ""
              func_append = "_#{i}" if funcs.size > 1

              # Assumption: functions taking a callback only have one argument: the callback
              wrapper_name = if func.arguments.size == 1 && (fp = func.arguments[0].cpp_type.base_type).is_a?(RbGCCXML::FunctionType)
                               Logger.info "Building callback wrapper for #{func.qualified_name}"
                               build_function_callback_wrapper(func, fp, func_append)
                             else
                               wrap_name = funcs.size > 1 ? build_function_wrapper(func, func_append) : func.qualified_name
                               func.special_qualified_name || wrap_name
                             end

              if func.return_type.const? || func.const?
                TypesManager.build_const_converter(func.return_type)
              end

              ruby_name = "#{Inflector.underscore(func.name)}#{func_append}"
              body << "\tdefine_global_function(\"#{ruby_name}\", &#{wrapper_name});"
            end
          end
          
          build_enumerations
          build_classes
        end

        build_modules
      end

      def build_modules
        @modules.each do |mod|
          Logger.info "Generating module #{mod.name}"
          builder = ModuleBuilder.new(self, mod)
          builder.build
          builders << builder
        end
      end

      # Finish up the required code before doing final output
      def to_s
        includes << "using namespace Rice;"
        
        super + "\n}"
      end
    end
  end
end
