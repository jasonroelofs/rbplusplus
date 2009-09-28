module RbPlusPlus
  module Builders
    module EnumerationHelpers

      # Wrap up enumerations for this node.
      # Anonymous enumerations are a special case. C++ doesn't
      # see them as a seperate type and instead are just "scoped" constants,
      # so we have to wrap them as such, constants.
      def with_enumerations
        [self.code.enumerations].flatten.each do |enum|
          next if do_not_wrap?(enum)

          if enum.anonymous?
            # So for each value of this enumeration, 
            # expose it as a constant
            enum.values.each do |value|
              add_child ConstNode.new(value, self)
            end
          else
            add_child EnumerationNode.new(enum, self)
          end

        end
      end

    end
  end
end
