module RbPlusPlus
  module Builders

    # Node for an #include line.
    # Can be a :local (default) or :system
    # include declaration.
    #
    # Includes have no children
    class IncludeNode < Base

      def initialize(parent, path, type = :local)
        super(nil, parent)

        @path = path
        @type = type
      end

      def build
        #nop
      end

      def write
        if @path
          includes << (@type == :local ? "#include \"#{@path}\"" : "#include <#{@path}>")
        end
      end

    end

  end
end

