module RbPlusPlus
  module Builders

    # This class handles generating source for a requested Enumeration
    class EnumerationBuilder < Base
      
      # Different initializer to keep things clean
      def initialize(parent, node)
        super(node.name, node)
        self.parent = parent
      end

      def build
        if node.anonymous?
          build_as_const
          return
        end

        includes << "#include <rice/Enum.hpp>"
        enum_name = node.name
        full_name = node.qualified_name
        self.rice_variable = "rb_e#{enum_name}"
        self.rice_variable_type = "Rice::Enum<#{full_name}>"
        
        add_additional_includes
        
        defn = "\t#{rice_variable_type} #{rice_variable} = "
        
        second_arg = ""
        if !parent.is_a?(ExtensionBuilder)
          second_arg = ", #{parent.rice_variable}"
        end

        TypesManager.build_const_converter(node)

        defn += "Rice::define_enum<#{full_name}>(\"#{enum_name}\" #{second_arg});"

        body << defn

        node.values.each do |v|
          body << "\t#{rice_variable}.define_value(\"#{v.name}\", #{v.to_s(true)});"
        end
      end

      # Anonymous enumerations don't fit the Enum type definitions
      # we do below. In C++ they act as just another constant, so 
      # we shall define them as such in the extension
      def build_as_const
        scope = 
          if parent.is_a?(ExtensionBuilder) 
            "Module(rb_mKernel)"
          else
            parent.rice_variable
          end

        node.values.each do |v|
          body << "\t#{scope}.const_set(\"#{v.name}\", to_ruby((int)#{v.to_s(true)}));"
        end
      end

    end
  end
end
