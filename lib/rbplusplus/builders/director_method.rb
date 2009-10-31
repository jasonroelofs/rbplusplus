module RbPlusPlus
  module Builders

    # Expose a director method as an instance method
    class DirectorMethodNode < MethodNode

      def initialize(method, parent, director)
        super(method, parent)
        @director = director
      end

      def code_path
        cpp_name = self.code.qualified_name.split("::")[-1]
        "#{@director.qualified_name}::default_#{cpp_name}"
      end

    end

  end
end
