module RbPlusPlus
  module Builders

    # Wrap class constructor(s)
    class ConstructorNode < Base

      def build
        add_child IncludeNode.new(self, "rice/Constructor.hpp", :system)
      end

      def write
        args = [code.qualified_name, code.arguments.map {|a| a.cpp_type.qualified_name }].flatten
        registrations << "#{parent.rice_variable}.define_constructor(Rice::Constructor<#{args.join(",")}>());"
      end

    end

  end
end
