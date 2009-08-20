module RbPlusPlus
  module Builders

    # Expose an enumeration.
    class EnumerationNode < Base

      def build
        nodes << IncludeNode.new(self, "rice/Enum.hpp", :system)
        nodes << IncludeNode.new(self, code.file)
      end

      def write
        var_type = "Rice::Enum<#{code.qualified_name}>"
        var_name = "rb_e#{code.name}"

        registrations << "#{var_type} #{var_name} = " \
          "Rice::define_enum<#{code.qualified_name}>(\"#{code.name}\");"

        code.values.each do |v|
          registrations << '%s.define_value("%s", %s);' % [var_name, v.name, v.qualified_name]
        end
      end

    end
  end
end
