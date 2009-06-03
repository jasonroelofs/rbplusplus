module RbPlusPlus
  module Builders

    # This class handles generating source for Class nodes that
    # have virtual and pure-virtual methods. With these, we need a
    # proxy class to handle the method routing to allow polymorphism
    # to work between C++ and Ruby seemlessly
    #
    # TODO There's probably a good way to make ClassBuilder and this class
    # similar (DirectorBuilder < ClassBuilder ?), but not going to worry about that right now.
    class DirectorBuilder < Base

      # Different initializer to keep things clean
      def initialize(parent, node)
        super(node.name, node)
        self.parent = parent
      end

      def build
        # First, find out if there's a Typedef for this class.
        # Make sure that if there is a Typedef tree that we find
        # the lowest of this tree to ensure we don't get massive
        # definitions with nested template declarations
        found = last_found = node
        if !node._disable_typedef_lookup?
          while found
            last_found = found
            typedef = RbGCCXML::XMLParsing.find(:node_type => "Typedef", :type => found.attributes["id"])

            # Some typedefs have the access attribute, some don't. We want those without the attribute
            # and those with the access="public". For this reason, we can't put :access => "public" in the
            # query above.
            found = (typedef && typedef.public?) ? typedef : nil
          end
        end

        if last_found != node
          typedef = last_found
          self.class_type = typedef.qualified_name
          wrapping = typedef.qualified_name

          @class_name = typedef.name
          Logger.debug("Found typedef #{typedef.qualified_name} for #{node.qualified_name}")
        else
          self.class_type = node.qualified_name
          @class_name = node.name
          wrapping = node.qualified_name
        end

#        self.declarations.insert(0,"typedef #{node.qualified_name} #{self.class_type};")

        Logger.info "Wrapping class #{wrapping} with a Director"

        #Handles templated super classes passing in complex members
        var_name = node.name.functionize
        @director_name = "#{@class_name}Director"

        self.rice_variable = "rb_c#{var_name}"
        self.rice_variable_type = "Rice::Data_Type<#{@director_name} >"

        includes << "#include <rice/Class.hpp>"
        includes << "#include <rice/Data_Type.hpp>"
        includes << "#include <rice/Constructor.hpp>"
        includes << "#include <rice/Director.hpp>"

        add_additional_includes
        add_includes_for node

        # Write out any custom code declarations given to us
        # by the wrapping code
        node._get_custom_declarations.flatten.each do |decl|
          @declarations << decl
        end

        # Need to tell Rice of the base class
        @body << "\tRice::define_class<#{self.class_type} >(\"__#{self.name}__\");"

        @body << class_definition

        @body += constructors
        @body += methods
        @body += constants

        # And write out the custom mappings related
        # to the custom declarations
        node._get_custom_wrappings.flatten.each do |wrap|
          @body << "\t#{wrap.gsub(/<class>/, rice_variable)}"
        end

        # Expose any public instance variables
        public_ivars

        # Nested Classes
        build_classes

        # Enumerations
        build_enumerations
      end

      # Loop through the constants for this class and wrap them up.
      def constants
        result = []
        [node.constants.find(:access => :public)].flatten.each do |constant|
          next if constant.ignored? || constant.moved?
          # If this constant is initialized in the header, we need to set the constant to the initialized value
          # If we just use the variable itself, Linux will fail to compile because the linker won't be able to
          # find the constant.
          set_to =
            if init = constant.attributes["init"]
              init
            else
              constant.qualified_name
            end
          result << "\t#{rice_variable}.const_set(\"#{constant.name}\", to_ruby(#{set_to}));"
        end
        result
      end

      # Build the constructors, and return an array of rice code
      def constructors
        result = []

        # Constructors
        to_use = node._get_constructor

        if to_use.nil? && node.constructors.length > 1
          Logger.warn :multiple_constructors, "#{node.qualified_name} has multiple constructors. While the extension will probably compile, Rice only supports one custructor, please use #use_contructor to select which one to use."
        end

        using = []

        [to_use || node.constructors].flatten.each do |init|
          next if init.ignored? || !init.public?

          # For safety's sake, we also ignore the generated copy constructor
          next if init.attributes[:artificial] && init.arguments.length == 1

          using << init
        end

        if using.empty?
          # We do this to ensure there's always a constructor definition for the director class.
          # Otherwise, subclasses can't work because there's no allocator defined.
          args = [@director_name, "Rice::Object"]
          result << "\t#{rice_variable}.define_constructor(Rice::Constructor<#{args.join(",")}>());"
        else
          using.each do |init|
            args = [@director_name, "Rice::Object", init.arguments.map {|a| a.cpp_type.to_s(true) }].flatten
            result << "\t#{rice_variable}.define_constructor(Rice::Constructor<#{args.join(",")}>());"
          end
        end

        result
      end

      # Find all public instance variables and expose them as
      # variable and variable=.
      # Because Rice doesn't support this internally yet, we need to
      # generate helper methods and wrap into those
      def public_ivars
        [node.variables.find(:access => :public)].flatten.each do |var|
          next if var.ignored? || var.moved?

          # Setter, only if it isn't const
          if !var.cpp_type.const?
            method_name = "wrap_#{node.qualified_name.functionize}_#{var.name}_set"
            declarations << "void #{method_name}(#{node.qualified_name}* self, #{var.cpp_type.to_s(true)} val) {"
            declarations << "\tself->#{var.name} = val;"
            declarations << "}"

            body << "\t#{self.rice_variable}.define_method(\"#{var.name}=\", &#{method_name});"
          end

          # Getter
          method_name = "wrap_#{node.qualified_name.functionize}_#{var.name}_get"
          declarations << "#{var.cpp_type.to_s(true)} #{method_name}(#{node.qualified_name}* self) {"
          declarations << "\treturn self->#{var.name};"
          declarations << "}"

          body << "\t#{self.rice_variable}.define_method(\"#{var.name}\", &#{method_name});"
        end
      end

      # Build the methods, and return an array of rice code
      def methods
        result = []
        # Methods are thrown into a hash table so that we can
        # determine overloaded methods
        methods_hash = {}
        [node.methods].flatten.each do |method|
          # Ignore all non-public methods
          next unless method.public?

          # Ignore methods that have non-public arguments anywhere
          if !method.arguments.empty? && !method.arguments.select {|a| !a.cpp_type.base_type.public?}.empty?
            Logger.info "Ignoring method #{method.qualified_name} due to non-public argument type(s)"
            next
          end

          methods_hash[method.qualified_name] ||= []
          methods_hash[method.qualified_name] << method
        end

        methods_hash.each do |key, methods|
          #Add any method with a const return type to the typemanager
          methods.each_with_index do |method, i|
            next if method.ignored? || method.moved?
            if method.return_type.const? || method.const?
              TypesManager.build_const_converter(method.return_type)
            end

            # Need to handle a number of side cases here:
            #
            # * Normal wrapped method
            # * Normal wrapped static method
            # * Overloaded method
            # * Overloaded static method
            #
            # Along with
            #
            # * possiblity of requiring a callback

            method_append = methods.length == 1 ? "" : "_#{i}"

            if @wrapped_methods.include?(method.name)
              rice_method = "define_method"
              wrapped_name = "#{@director_name}::#{method.rbgccxml_name}"
            elsif method.static?
              rice_method = "define_singleton_method"
              wrapped_name = build_function_wrapper(method, method_append)
            else
              rice_method = "define_method"
              wrapped_name = build_method_wrapper(node, method, method_append)
            end

            method_name = "#{Inflector.underscore(method.name)}"
            method_name += method_append unless method.renamed?

            result << "\t#{rice_variable}.#{rice_method}(\"#{Inflector.underscore(method_name)}\", &#{wrapped_name});"
          end
        end
        result
      end

      # Return a rice string representing Rice's class definition.
      def class_definition
        class_defn = "\t#{rice_variable_type} #{rice_variable} = "

        build_director

        class_name = node.name
        supers = node.superclasses(:public)

        if supers.length > 1
          if node._get_superclass.nil?
            Logger.warn :mutiple_subclasses, "#{@class_name} has multiple public superclasses. " +
              "Will use first superclass, which is #{supers[0].qualified_name} "
              "Please use #use_superclass to specify another superclass as needed."
            superclass = supers[0]
          else
            superclass = node._get_superclass
          end
        else
          superclass = supers[0]
        end

        class_names = [@director_name, self.class_type].join(",")

        if !parent.is_a?(ExtensionBuilder)
          class_defn += "Rice::define_class_under<#{class_names} >(#{parent.rice_variable}, \"#{@class_name}\");"
        else
          class_defn += "Rice::define_class<#{class_names} >(\"#{@class_name}\");"
        end
        class_defn
      end

      # Build the Director proxy class
      # Returns the list of methods wrapped in this proxy
      def build_director
        @wrapped_methods = []

        # Constructors
        to_use = node._get_constructor

        if to_use.nil? && node.constructors.length > 1
          Logger.warn :multiple_constructors, "#{node.qualified_name} has multiple constructors. For the purposes of the Director, the first constructor found will be used. Rice only supports one custructor, please use #use_contructor to select which one to use."
        end

        constructor = nil
        [to_use || node.constructors].flatten.each do |init|
          next if init.ignored? || !init.public?

          # For safety's sake, we also ignore the generated copy constructor
          next if init.attributes[:artificial] && init.arguments.length == 1
          constructor = init
          break
        end

        # If we can't find a constructor, then we simply super the default constructor
        if constructor
          args = ["Rice::Object self", constructor.arguments.map {|a| "#{a.cpp_type.to_s(true)} #{a.name}" }].flatten
          args_use = constructor.arguments.map {|a| a.name }
          super_cons = ", #{self.class_type}(#{args_use.join(",")})"
        else
          args = ["Rice::Object self"]
          args_use = []
          super_cons = ", #{self.class_type}()"
        end


        declarations << "class #{@director_name} : public #{self.class_type}, public Rice::Director {"
        declarations << "\tpublic:"
        declarations << "\t\t#{@director_name}(#{args.join(",")}) :
          Rice::Director(self)#{super_cons} {  }"

        [node.methods].flatten.each do |m|
          next if m.ignored? || m.moved? || !m.public?

          # Only wrap virtual methods.
          next unless m.virtual?

          ruby_name = Inflector.underscore(m.name)

          arg_types = m.arguments.map {|a| "#{a.cpp_type.to_s(true)} #{a.name}"}.join(", ")
          arg_calls = m.arguments.map {|a| a.name }
          returns = m.return_type == "void" ? "" : "return "

          if m.default_return_value
            raise_or_return = "return #{m.default_return_value};"
            reverse = "!"
          else
            raise_or_return = "raisePureVirtual();"
            reverse = ""
          end

          raise_or_call = m.purely_virtual? ? raise_or_return : "#{returns}this->#{m.qualified_name}(#{arg_calls.join(", ")});"
          self_call = %Q(getSelf().call(#{[%Q("#{ruby_name}"), arg_calls].flatten.join(", ")}))

          if returns == "return "
            self_call = "return from_ruby<#{m.return_type.to_s(true)}>( #{self_call} )"
          end

          declarations << "   #{m.return_type.to_s(true)} #{m.rbgccxml_name}(#{arg_types}) {"
          declarations << "     if(#{reverse}callIsFromRuby(\"#{ruby_name}\")) {"
          declarations << "       #{raise_or_call}"
          declarations << "     } else {"
          declarations << "       #{self_call};"
          declarations << "     }"
          declarations << "   }"

          @wrapped_methods << m.name
        end

        declarations << "};"
      end
    end
  end
end
