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
                               build_callback_wrapper(func, fp, func_append)
                             else
                               func.special_qualified_name || build_function_wrapper(func, func_append)
                             end

              if func.return_type.const? || func.const?
                Logger.info "Creating converter for #{func.return_type.qualified_name}"
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

      # Build up C++ code to properly wrap up methods to take ruby block arguments
      # which forward off calls to callback functions.
      #
      # This works as such. We need two functions here, one to be the wrapper into Ruby 
      # and one to be the wrapper around the callback function. 
      #
      # The method wrapped into Ruby takes straight Ruby objects
      #
      # Current assumption: The callback argument is the only argument of the method
      def build_callback_wrapper(function, func_pointer, append)
        func_name = function.qualified_name.functionize
        yielding_method_name = "do_yeild_on_#{func_name}"
        wrapper_func = "wrap_for_callback_#{func_name}#{append}"

        fp_arguments = func_pointer.arguments
        fp_return = func_pointer.return_type

        returns = fp_return.to_s

        # The callback wrapper method.
        block_var_name = "_block_for_#{func_name}"
        declarations << "VALUE #{block_var_name};"
        declarations << "#{returns} #{yielding_method_name}(#{function_arguments_string(func_pointer, true)}) {"

        num_args = fp_arguments.length
        args_string = "#{num_args}"
        if num_args > 0
          args_string += ", #{function_arguments_list(func_pointer).map{|c| "to_ruby(#{c}).value()"}.join(",") }"
        end

        funcall = "rb_funcall(#{block_var_name}, rb_intern(\"call\"), #{args_string})"
        if returns == "void"
          declarations << "\t#{funcall};"
        else
          declarations << "\treturn from_ruby<#{returns}>(#{funcall});"
        end
        declarations << "}"

        # The method to get wrapped into Ruby
        declarations << "VALUE #{wrapper_func}(Rice::Object self) {"
        declarations << "\t#{block_var_name} = rb_block_proc();"
        declarations << "\t#{function.qualified_name}(&#{yielding_method_name});"
        declarations << "\treturn Qnil;"
        declarations << "}"

        wrapper_func
      end

      # Finish up the required code before doing final output
      def to_s
        includes << "using namespace Rice;"
        
        super + "\n}"
      end
    end
  end
end
