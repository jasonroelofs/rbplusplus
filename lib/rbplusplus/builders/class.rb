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

        @short_name, @qualified_name = find_typedef || [code.name, code.qualified_name]

        Logger.info "Wrapping class #{@qualified_name}"

        self.rice_variable = "rb_c#{as_variable(@short_name)}"
        self.rice_variable_type = "Rice::Data_Type< #{@qualified_name} >"

        supers = self.code.superclasses(:public)
        @superclass = supers[0]

        if supers.length > 1
          if (@superclass = self.code._get_superclass).nil?
            Logger.warn :mutiple_subclasses, "#{@qualified_name} has multiple public superclasses. " +
              "Will use first superclass, which is #{supers[0].qualified_name} "
              "Please use #use_superclass to specify another superclass as needed."
          end
        end

      end

      def write
        prefix = "#{rice_variable_type} #{rice_variable} = "

        class_names = [@qualified_name]
        class_names << @superclass.qualified_name if @superclass && !do_not_wrap?(@superclass)
        class_names = class_names.join(",")

        if parent.rice_variable
          registrations << "#{prefix} Rice::define_class_under< #{class_names} >" +
                             "(#{parent.rice_variable}, \"#{@short_name}\");"
        else
          registrations << "#{prefix} Rice::define_class< #{class_names} >(\"#{@short_name}\");"
        end

        handle_custom_code
      end

      private

      # Here we take the code manually added to the extension via #add_custom_code
      def handle_custom_code

        # Any declaration code, usually wrapper function definitions
        self.code._get_custom_declarations.flatten.each do |decl|
          declarations << decl
        end

        # And the registration code to hook into Rice
        self.code._get_custom_wrappings.flatten.each do |wrap|
          registrations << "#{wrap.gsub(/<class>/, self.rice_variable)}"
        end
      end

    end

  end
end
