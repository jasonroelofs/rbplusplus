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
        includes << "#include \"#{node.file_name(false)}\""

        class_defn = "\t#{rice_variable_type} #{rice_variable} = "
        if !parent.is_a?(ExtensionBuilder)
          class_defn += "Rice::define_class_under<#{full_name}>(#{parent.rice_variable}, \"#{class_name}\");"
        else
          class_defn += "Rice::define_class<#{full_name}>(\"#{class_name}\");"
        end

        body << class_defn

        # Constructors
        node.constructors.each do |init|
          args = [full_name, init.arguments.map {|a| a.cpp_type.to_s(true) }].flatten
          body << "\t#{rice_variable}.define_constructor(Rice::Constructor<#{args.join(",")}>());"
        end

        # Methods
        node.methods.each do |method|
          m = "define_method"
          name = method.qualified_name

          if method.static?
            m = "define_singleton_method"
            name = build_function_wrapper(method)
          end
          
          if method.return_type.const?
            build_const_converter(method.return_type)
          end

          body << "\t#{rice_variable}.#{m}(\"#{Inflector.underscore(method.name)}\", &#{name});"
        end

        # Nested Classes
        node.classes.each do |klass|
          b = ClassBuilder.new(self, klass)
          b.build
          builders << b
        end
      end

    end
  end
end
