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
        full_name = node.qualified_name
        self.rice_variable = "rb_c#{class_name}"
        self.rice_variable_type = "Rice::Data_Type<#{full_name}>"

        includes << "#include <rice/Class.hpp>"
        includes << "#include <rice/Data_Type.hpp>"
        includes << "#include <rice/Constructor.hpp>"  
        
        class_defn = "\t#{rice_variable_type} #{rice_variable} = "
        add_includes_for node
        add_additional_includes
        
        supers = node.super_classes        
        super_names = supers.collect { |s| s.qualified_name }.join(",")
        
        if !parent.is_a?(ExtensionBuilder)
          class_defn += "Rice::define_class_under<#{super_names} >(#{parent.rice_variable}, \"#{class_name}\");"
        else
          class_defn += "Rice::define_class<#{super_names} >(\"#{class_name}\");"
        end

        body << class_defn

        # Constructors
        node.constructors.each do |init|
          next if init.ignored?
          next unless init.public?
          args = [full_name, init.arguments.map {|a| a.cpp_type.to_s(true) }].flatten
          body << "\t#{rice_variable}.define_constructor(Rice::Constructor<#{args.join(",")}>());"
        end

        # Methods
        node.methods.each do |method|
          next if method.ignored?
          next unless method.public?
          
          m = "define_method"
          name = method.qualified_name

          if method.static?
            m = "define_singleton_method"
            name = build_function_wrapper(method)
          end

          body << "\t#{rice_variable}.#{m}(\"#{Inflector.underscore(method.name)}\", &#{name});"
        end

        # Nested Classes
        node.classes.each do |klass|
          next if klass.ignored?
          b = ClassBuilder.new(self, klass)
          b.build
          builders << b
        end
      end

    end
  end
end
