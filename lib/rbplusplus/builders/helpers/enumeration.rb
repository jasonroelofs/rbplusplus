module RbPlusPlus
  module Builders
    module EnumerationHelpers

      # Wrap up enumerations for this node.
      # Anonymous enumerations are a special case. C++ doesn't
      # see them as a seperate type and instead are just "scoped" constants,
      # so we have to wrap them as such, constants.
      def with_enumerations
        self.code.enumerations.each do |enum|
          next if enum.ignored? || enum.moved? || !enum.public? 

          if enum.anonymous?
            # So for each value of this enumeration, 
            # expose it as a constant
            enum.values.each do |value|
              node = ConstNode.new(value, self)
              node.build
              nodes << node
            end
          else
            node = EnumerationNode.new(enum, self)
            node.build
            nodes << node
          end

        end
      end

    end
  end
end
