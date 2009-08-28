module RbPlusPlus
  module Builders

    # Handles the generation of Rice code to wrap classes
    class ClassNode < Base
      include ClassHelpers
      include EnumerationHelpers

      def build
        nodes << IncludeNode.new(self, "rice/Class.hpp", :system)
        nodes << IncludeNode.new(self, "rice/Data_Type.hpp", :system)
        nodes << IncludeNode.new(self, code.file)

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

        if parent.rice_variable
          registrations << "#{prefix} Rice::define_class_under< #{code.qualified_name} >" +
                             "(#{parent.rice_variable}, \"#{code.name}\");"
        else
          registrations << "#{prefix} Rice::define_class< #{code.qualified_name} >(\"#{code.name}\");"
        end
      end

    end

  end
end
