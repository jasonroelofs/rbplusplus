module RbPlusPlus
  module Builders

    # Handles code generation for telling Rice how to allocate / deallocate
    # classes. See ClassNode#check_allocation_strategies.
    class AllocationStrategyNode < Base

      def initialize(parent, code, has_public_constructor, has_public_destructor)
        super(code, parent)
        @public_constructor = has_public_constructor
        @public_destructor = has_public_destructor
      end

      def build
        add_child IncludeNode.new(self, "rice/Allocation_Strategies.hpp", :system)
      end

      def write
        node_name = self.code.qualified_name
        code = <<-END 
namespace Rice {
  template<>
  struct Default_Allocation_Strategy< #{node_name} > {
    static #{node_name} * allocate();
    static void free(#{node_name} * obj);
  };
}
        END

        declarations << code

        pre = "Rice::Default_Allocation_Strategy< #{node_name} >::"

        tmp = "#{node_name} * #{pre}allocate() { return "
        tmp += @public_constructor ? "new #{node_name};" : "NULL;"
        tmp += " }"

        registrations << tmp

        tmp = "void #{pre}free(#{node_name} * obj) { "
        tmp += @public_destructor ? "delete obj;" : ""
        tmp += " }"

        registrations << tmp
      end

    end

  end
end

