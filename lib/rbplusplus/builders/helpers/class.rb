module RbPlusPlus
  module Builders
    module ClassHelpers

      # Build up any classes or structs under this module
      def with_classes
        [
          self.code.classes,
          self.code.structs
        ].flatten.each do |klass|
          next if do_not_wrap?(klass)
          add_child ClassNode.new(klass, self)
        end
      end

      # Wrap any constructors for this class
      def with_constructors
        # Ignore constructors on classes that have pure virtual methods,
        # as they aren't constructable
        return if !@director && self.code.pure_virtual?

        to_use = self.code._get_constructor

        real_constructors = [self.code.constructors].flatten.select {|c| !c.attributes[:artificial]}

        if real_constructors.empty?
          real_constructors = self.code.constructors
        else
          ignore_artificial = true
        end

        if to_use.nil? && real_constructors.length > 1
          Logger.warn :multiple_constructors, "#{self.code.qualified_name} has multiple constructors. " +
            "While the extension will probably compile, Rice only supports one constructor, " +
            "please use #use_contructor to select which one to use."
        end

        [to_use || real_constructors].flatten.each do |constructor|
          next if do_not_wrap?(constructor)

          Logger.debug "Wrapping constructor: #{constructor.attributes["demangled"]}"

          if constructor.attributes["artificial"]
            if ignore_artificial && constructor.arguments.length == 1
              Logger.debug "Not wrapping artificial constructor #{constructor.attributes["demangled"]}"
              next 
            end
          end

          if implicit_casting?(constructor)
            Logger.debug "Wrapping implicit constructor #{constructor.to_cpp}"
            parent.add_child ImplicitCasterNode.new(constructor, self)
            next
          end

          if @director
            @director.wrap_constructor constructor
          else
            add_child ConstructorNode.new(constructor, self)
          end
        end
      end

      # Is this constructor a converter constructor?
      def implicit_casting?(constructor)
        constructor.implicit_casting? &&
          # Only works on single argument constructors
          constructor.arguments.length == 1 &&
          # We are wrapping the type converting from
          !do_not_wrap?(constructor.arguments[0].cpp_type.base_type)
      end

      # Wrap up any class constants
      def with_constants
        [self.code.constants].flatten.each do |const|
          next if do_not_wrap?(const)
          add_child ConstNode.new(const, self)
        end
      end

      # Expose the public variables for this class
      def with_variables
        [self.code.variables].flatten.each do |var|
          next if do_not_wrap?(var)

          add_child InstanceVariableNode.new(var, self)
        end
      end

    end
  end
end
