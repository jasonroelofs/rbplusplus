module RbPlusPlus
  module Builders

    # This class handles generating source for Class nodes
    class ClassBuilder < Base

      # Different initializer to keep things clean
      def initialize(parent, node)
        super(node.name, node)
        self.parent = parent
      end

      def build
        class_name = node.name

        #Handles templated super classes
        typedef_name = node.qualified_name
        typedef_name.gsub!("::","_")
        typedef_name.gsub!(/[ ,<>]/, "_")
        typedef_name.gsub!("*", "Ptr")
        
        #Handles templated super classes passing in complex members
        var_name = node.name
        var_name.gsub!("::","_")
        var_name.gsub!(/[ ,<>]/, "_")
        var_name.gsub!("*", "Ptr")
        
        self.rice_variable = "rb_c#{var_name}"
        self.rice_variable_type = "Rice::Data_Type<#{self.qualified_name} >"

        includes << "#include <rice/Class.hpp>"
        includes << "#include <rice/Data_Type.hpp>"
        includes << "#include <rice/Constructor.hpp>"  
        
        class_defn = "\t#{rice_variable_type} #{rice_variable} = "
        add_includes_for node
        add_additional_includes
        
        
        self.declarations.insert(0,"typedef #{node.qualified_name} #{typedef_name};")
        
        supers = node.super_classes.collect { |s| s.qualified_name }
        
        class_names = [typedef_name, supers].flatten.join(",")
        
        if !parent.is_a?(ExtensionBuilder)
          class_defn += "Rice::define_class_under<#{class_names} >(#{parent.rice_variable}, \"#{class_name}\");"
        else
          class_defn += "Rice::define_class<#{class_names} >(\"#{class_name}\");"
        end

        body << class_defn

        # Constructors
        node.constructors.each do |init|
          next if init.ignored?
          next unless init.public?
          args = [typedef_name, init.arguments.map {|a| a.cpp_type.to_s(true) }].flatten
          body << "\t#{rice_variable}.define_constructor(Rice::Constructor<#{args.join(",")}>());"
        end

        # Methods
        node.methods.each do |method|
          next if method.ignored? || method.moved?
          next unless method.public?
         
          m = "define_method"
          name = method.qualified_name

          if method.static?
            m = "define_singleton_method"
            name = build_function_wrapper(method)
          end
          
          if method.return_type.const?
            TypesManager.build_const_converter(method.return_type)
          end

          body << "\t#{rice_variable}.#{m}(\"#{Inflector.underscore(method.name)}\", &#{name});"
        end

        # Nested Classes
        build_classes

        # Enumerations
        build_enumerations
      end

    end
  end
end
