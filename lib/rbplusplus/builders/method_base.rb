module RbPlusPlus
  module Builders

    # Base class for any type of method or function handling
    class MethodBase < Base

      attr_accessor :prefix, :rice_method

      def write
        ruby_name = Inflector.underscore(code.name)
        self.prefix ||= "#{self.parent.rice_variable}."
        registrations << "#{self.prefix}#{self.rice_method}(\"#{ruby_name}\", &#{code.qualified_name});"
      end

    end

  end
end
