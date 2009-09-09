module RbPlusPlus
  module Builders

    # Expose an enumeration.
    class EnumerationNode < Base

      def build
        add_child IncludeNode.new(self, "rice/Enum.hpp", :system)
        add_child IncludeNode.new(self, code.file)

        self.rice_variable_type = "Rice::Enum<#{code.qualified_name}>"
        self.rice_variable = "rb_e#{code.name}"

        Logger.info "Wrapping enumeration #{code.qualified_name}"
      end

      def write
        second = parent.rice_variable ? ", #{parent.rice_variable}" : ""

        registrations << "#{rice_variable_type} #{rice_variable} = " \
          "Rice::define_enum<#{code.qualified_name}>(\"#{code.name}\"#{second});"

        code.values.each do |v|
          registrations << "#{rice_variable}.define_value(\"#{v.name}\", #{v.qualified_name});"
        end
      end

    end
  end
end
