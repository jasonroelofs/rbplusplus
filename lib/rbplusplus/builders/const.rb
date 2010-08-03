module RbPlusPlus
  module Builders

    # Expose a const value
    class ConstNode < Base

      def build
        add_child IncludeNode.new(self, code.file)
      end

      def write
        # If this constant is initialized in the header, we need to set the constant to the initialized value
        # If we just use the variable itself, Linux will fail to compile because the linker won't be able to
        # find the constant.
        set_to =
          if init = code.attributes["init"]
            init
          else
            code.qualified_name
          end

        prefix = parent.rice_variable ? "#{parent.rice_variable}." : "Rice::Module(rb_mKernel)."
        registrations << "\t#{prefix}const_set(\"#{code.name}\", to_ruby(#{set_to}));"
      end

    end

  end
end

