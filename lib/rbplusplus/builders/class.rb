module RbPlusPlus
  module Builders

    # Handles the generation of Rice code to wrap classes
    class ClassNode < Base
      include ClassHelpers
      include EnumerationHelpers

      def qualified_name
        @qualified_name || self.code.qualified_name
      end

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

        check_allocation_strategies

        # For now, build a const& type converter for this type
        # TODO Remove this once we figure out how to put it in Rice directly
        add_global_child ConstConverterNode.new(self.code, self)

        @short_name, @qualified_name = find_typedef || [code.name, code.qualified_name]

        Logger.info "Wrapping class #{@qualified_name}"

        self.rice_variable = "rb_c#{@short_name.as_variable}"
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

      # We need to be sure to inform Rice of classes that may not have public
      # constructors or destructors. This is because when a class is wrapped, code is generated
      # to allocate the class directly. If this code tries to use a non-public
      # constructor, we hit a compiler error.
      def check_allocation_strategies
        # Due to the nature of GCC-XML's handling of templated classes, there are some
        # classes that might not have any gcc-generated constructors or destructors.
        # We check here if we're one of those classes and completely skip this step
        return if [self.code.constructors].flatten.empty?

        # Find a public default constructor
        found = [self.code.constructors.find(:arguments => [], :access => "public")].flatten
        has_public_constructor = !found.empty?

        # See if the destructor is public
        has_public_destructor = self.code.destructor && self.code.destructor.public?

        if !has_public_constructor || !has_public_destructor
          add_global_child AllocationStrategyNode.new(self,
                            self.code, has_public_constructor, has_public_destructor)
        end
      end

    end

  end
end
