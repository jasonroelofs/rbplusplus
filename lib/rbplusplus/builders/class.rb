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
      
        add_includes_for node
        add_additional_includes

        class_defn = "\t#{rice_variable_type} #{rice_variable} = "
        if !parent.is_a?(ExtensionBuilder)
          class_defn += "Rice::define_class_under<#{full_name}>(#{parent.rice_variable}, \"#{class_name}\");"
        else
          class_defn += "Rice::define_class<#{full_name}>(\"#{class_name}\");"
        end

        body << class_defn

        # Constructors
        node.constructors.each do |init|
          demangled = init.attributes["demangled"]
          constructor_args = demangled.split(/[\(,\)]/)
          constructor_args.delete_at 0

          args = [full_name, constructor_args].flatten
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
