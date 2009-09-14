module RbPlusPlus
  module Builders

    # Base class for any type of method or function handling
    class MethodBase < Base

      attr_accessor :prefix, :rice_method, :suffix

      def initialize(code, parent = nil)
        super

        # Overload checks:
        #  - If we're the only one, no overload required
        #  - If we're one of many w/ the same name:
        #     - Find out which in the list we are
        #     - Add the number to ruby_name, unless user has renamed
        #     - Build typedef of the method and use it in the exposure
        found = [code.parent.methods(code.name)].flatten
        if found.length > 1 && !code.renamed?
          num = found.index(code)
          self.suffix = "_#{num}"
        end
      end

      # Wrap up this method making sure that overloads
      # are properly typedef'd to keep from compiler error from unresolvable types
      #
      # Thanks to Py++ for the appropriate C++ syntax for this.
      def write
        ruby_name = Inflector.underscore(code.name)
        self.prefix ||= "#{self.parent.rice_variable}."
        self.suffix ||= ""

        usage_ref = "#{self.code.name}_func_type"

        if self.code.static?
          method_ref = "*#{usage_ref}"
        else
          parts = "#{self.code.qualified_name}_func_type".split("::")
          method_ref = [parts[0..-2], "*#{parts[-1]}"].flatten.join("::")
        end

        arguments =
          self.code.arguments.inject([]) do |memo, arg|
            memo << "#{arg.cpp_type.to_cpp} #{arg.name}"
            memo
          end.join(", ")

        registrations << "{"

        registrations << "typedef #{self.code.return_type.to_cpp} ( #{method_ref} )( #{arguments} );"
        registrations << "#{self.prefix}#{self.rice_method}(\"#{ruby_name + self.suffix}\", #{usage_ref}( &#{code.qualified_name} ));"

        registrations << "}"
      end

    end

  end
end
