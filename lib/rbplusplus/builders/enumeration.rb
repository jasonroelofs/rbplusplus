module RbPlusPlus
  module Builders

    # This class handles generating source for a requested Module
    class EnumerationBuilder < Base
      
      # Different initializer to keep things clean
      def initialize(parent, node)
        super(node.name, node)
        self.parent = parent
      end

      def build
        includes << "#include <rice/Enum.hpp>"
        enum_name = node.name
        full_name = node.qualified_name
        self.rice_variable = "rb_e#{enum_name}"
        self.rice_variable_type = "Rice::Enum<#{full_name}>"
        
        defn = "\t#{rice_variable_type} #{rice_variable} = "
        
        second_arg = ""
        if !parent.is_a?(ExtensionBuilder)
          second_arg = ", #{parent.rice_variable}"
        end

        defn += "Rice::define_enum<#{full_name}>(\"#{enum_name}\" #{second_arg});"

        body << defn

        node.values.each do |v|
          body << "\t#{rice_variable}.define_value(\"#{v.name}\", #{v.to_s(true)});"
        end
      end

    end
  end
end
