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
        # First, find out if there's a Typedef for this class
        @typedef = RbGCCXML::XMLParsing.find(:node_type => "Typedef", :type => node.attributes["id"])
        if @typedef
          self.class_type = @typedef.qualified_name
          @class_name = @typedef.name
        else
          self.class_type = @typedef ? @typedef.name : node.qualified_name.functionize
          @class_name = node.name
          self.declarations.insert(0,"typedef #{node.qualified_name} #{self.class_type};")
        end
        
        #Handles templated super classes passing in complex members
        var_name = node.name
        var_name.gsub!("::","_")
        var_name.gsub!(/[ ,<>]/, "_")
        var_name.gsub!("*", "Ptr")
        
        self.rice_variable = "rb_c#{var_name}"
        self.rice_variable_type = "Rice::Data_Type<#{node.qualified_name} >"

        includes << "#include <rice/Class.hpp>"
        includes << "#include <rice/Data_Type.hpp>"
        includes << "#include <rice/Constructor.hpp>"  
        
        add_additional_includes
        add_includes_for node
        
        @body << class_definition
        
        @body += constructors
        
        @body += methods

        # Nested Classes
        build_classes

        # Enumerations
        build_enumerations
      end

      # Build the constructors, and return an array of rice code
      def constructors
        result = []
        # There are no constructors on purely virtual classes.
        node.methods.each do |method|
          next unless method.is_a? RbGCCXML::Method
          if method.purely_virtual?
            Logger.warn :pure_virtual, "Ignoring pure virtual method #{method.qualified_name}"
            return [] 
          end
        end
        # Constructors
        node.constructors.each do |init|
          next if init.ignored?
          next unless init.public?
          args = [self.class_type, init.arguments.map {|a| a.cpp_type.to_s(true) }].flatten
          result << "\t#{rice_variable}.define_constructor(Rice::Constructor<#{args.join(",")}>());"
        end
        result
      end
      
      # Build the methods, and return an array of rice code
      def methods
        result = []
        # Methods are thrown into a hash table so that we can 
        # determine overloaded methods
        methods_hash = {}
        node.methods.each do |method|
          next unless method.public?
  
          methods_hash[method.qualified_name] ||= []
          methods_hash[method.qualified_name] << method
        end
        
        methods_hash.each do |key, methods|
          #Add any method with a const return type to the typemanager
          methods.each do |method|
            next if method.ignored? || method.moved?
            if method.return_type.const? || method.const?
              TypesManager.build_const_converter(method.return_type)
            end
          end
          #No overloaded methods
          if methods.length == 1
            method = methods[0]
            next if method.ignored? || method.moved?
            m = "define_method"
            name = method.qualified_name

            if method.static?
              m = "define_singleton_method"
              name = build_function_wrapper(method)
            end

            result << "\t#{rice_variable}.#{m}(\"#{Inflector.underscore(method.name)}\", &#{name});"  
          else
            #Handle overloaded methods
            #currently we just append an index to them if they have not been renamed
            #for example getOrigin() and getOrigin(x,y) become
            #get_origin_0 and get_origin_1
            methods.each_with_index do |method, i|
              next if method.ignored? || method.moved?
              name = build_method_wrapper(node, method, i)
              m = "define_method"
              method_name = "#{Inflector.underscore(method.name)}"
              method_name += "_#{i}" unless method.renamed?
              result << "\t#{rice_variable}.#{m}(\"#{method_name}\", &#{name});"  
            end
          end
        end
        result
      end
      
      # Return a rice string representing Rice's class definition.
      def class_definition        
        class_defn = "\t#{rice_variable_type} #{rice_variable} = "
        
        class_name = node.name
        supers = node.super_classes.collect { |s| s.qualified_name }
        class_names = [self.class_type, supers].flatten.join(",")
        
        if !parent.is_a?(ExtensionBuilder)
          class_defn += "Rice::define_class_under<#{class_names} >(#{parent.rice_variable}, \"#{@class_name}\");"
        else
          class_defn += "Rice::define_class<#{class_names} >(\"#{@class_name}\");"
        end
        class_defn
      end
    end
    
  end
end
