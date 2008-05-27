module RbPlusPlus
  module Builders

    # This is a singleton class that takes care of handling any to_ruby and from_ruby 
    # definitions this wrapper might need. This is pulled out seperate from other builders
    # because of C++ coding and compiling restrictions. Mainly, 
    #
    # 1. All cpp/hpp files where Rice needs to know about a given type needs to know about any to_/from_ruby definitions of that type
    # 2. The actual definition of these methods can only be in one place or we get compiler redefinition errors.
    class TypesManager
      include Singleton

      # Forward off all calls to the singleton instance of this method. 
      # This allows one to use this class as if it's a bunch of class methods. E.g.:
      #
      #   TypesManager.build_const_converter(type)
      #
      def self.method_missing(method, *args)
        if TypesManager.instance.respond_to?(method)
          TypesManager.instance.send(method, *args)
        else
          super
        end
      end

      attr_accessor :body, :prototypes, :includes

      def initialize
        @consts_wrapped = []
        @body = []
        @prototypes = []
        @includes = []
      end

      # Rice doesn't automatically handle all to_ / from_ruby conversions for a given type.
      # A common construct is the +const Type&+ variable, which we need to manually handle.
      def build_const_converter(type)
        full_name = type.base_type.qualified_name

        # Only wrap once
        # TODO cleaner way of doing this
        return if @consts_wrapped.include?(full_name)

        @consts_wrapped << full_name

        @includes << "#include <rice/Object.hpp>"
        @includes << "#include <rice/Data_Object.hpp>"
        @includes << "#include <rice/Data_Type.hpp>"
        @includes << "#include \"#{type.base_type.file_name(false)}\""

        @body << "template<>"
        @body << "Rice::Object to_ruby<#{full_name}>(#{full_name} const & a) {"
        @body << "\treturn Rice::Data_Object<#{full_name}>((#{full_name} *)&a, Rice::Data_Type<#{full_name}>::klass(), 0, 0);"
        @body << "}"

        @prototypes << "template<>"
        @prototypes << "Rice::Object to_ruby<#{full_name}>(#{full_name} const & a);"
      end

    end
  end
end
