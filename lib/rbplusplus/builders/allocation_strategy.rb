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

      # Used by MultipleFileWriter to only wrap a given type once.
      def qualified_name
        "#{self.code.qualified_name}_AllocStrat"
      end

      def build
      end

      def write
        includes << "#include <rice/Data_Object.hpp>"

        node_name = self.code.qualified_name
        code = <<-END
namespace Rice {
  template<>
  struct Default_Free_Function< #{node_name} > {
    static void free(#{node_name} * obj);
  };
}
        END

        declarations << code

        pre = "Rice::Default_Free_Function< #{node_name} >::"

        tmp = "void #{pre}free(#{node_name} * obj) { "
        tmp += @public_destructor ? "delete obj;" : ""
        tmp += " }"

        registrations << tmp
      end

    end

  end
end

