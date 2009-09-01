module RbPlusPlus
  module Builders

    # Handles the generation of Rice code to wrap classes
    class ClassNode < Base
      include ClassHelpers
      include EnumerationHelpers

      def build
        add_child IncludeNode.new(self, "rice/Class.hpp", :system)
        add_child IncludeNode.new(self, "rice/Data_Type.hpp", :system)
        add_child IncludeNode.new(self, code.file)

        with_enumerations
        with_classes
        with_constructors
        with_constants
        with_variables
        with_methods
      end

      def write
        self.rice_variable = "rb_c#{as_variable(code.name)}"
        self.rice_variable_type = "Rice::Data_Type< #{code.qualified_name} >"

        prefix = "#{rice_variable_type} #{rice_variable} = "

        supers = self.code.superclasses(:public)
        superclass = supers[0]

        if supers.length > 1
          if (superclass = self.code._get_superclass).nil?
            Logger.warn :mutiple_subclasses, "#{self.code.qualified_name} has multiple public superclasses. " +
              "Will use first superclass, which is #{supers[0].qualified_name} "
              "Please use #use_superclass to specify another superclass as needed."
          end
        end

        class_names = [self.code.qualified_name]
        class_names << superclass.qualified_name if superclass && !do_not_wrap?(superclass)
        class_names = class_names.join(",")

        if parent.rice_variable
          registrations << "#{prefix} Rice::define_class_under< #{class_names} >" +
                             "(#{parent.rice_variable}, \"#{code.name}\");"
        else
          registrations << "#{prefix} Rice::define_class< #{class_names} >(\"#{code.name}\");"
        end
      end

    end

  end
end
