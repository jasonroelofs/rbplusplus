module RbPlusPlus
  module Builders

    # Expose a const value
    class ConstNode < Base

      def build
        nodes << IncludeNode.new(self, code.file)
      end

      def write
        prefix = parent.rice_variable ? "#{parent.rice_variable}." : "Rice::Module(rb_mKernel)."
        registrations << "#{prefix}const_set(\"#{code.name}\", to_ruby((int)#{code.qualified_name}));"
      end

    end

  end
end

