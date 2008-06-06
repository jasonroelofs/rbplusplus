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

      # Some libraries have really bad namespace declarations
      # so we allow for 2 methods of including files
      # 1.  trace the class definition to the parent file
      # 2.  explicitly declare which files to include in every generated source
      #
      def add_include_for(type)
        file = type.file_name(false)
        if Base.sources.include? file
          @includes << "#include \"#{file}\""
        else
          Base.sources.each do |header|
            @includes << "#include \"#{header}\""
          end
        end  
      end
      
      # Rice doesn't automatically handle all to_ / from_ruby conversions for a given type.
      # A common construct is the +const Type&+ variable, which we need to manually handle.
      def build_const_converter(type)
        type = type.is_a?(RbGCCXML::Type) ? type.base_type : type

        # Don't need to deal with fundamental types
        return if type.is_a?(RbGCCXML::FundamentalType)

        full_name = type.qualified_name

        # Only wrap once
        # TODO cleaner way of doing this
        return if @consts_wrapped.include?(full_name)

        @consts_wrapped << full_name

        # Enumerations are handled slightly differently
        class_type = if type.is_a?(RbGCCXML::Enumeration)
                       "new #{full_name}(a)"
                     else
                       "(#{full_name} *)&a"
                     end

        @includes << "#include <rice/Object.hpp>"
        @includes << "#include <rice/Data_Object.hpp>"
        @includes << "#include <rice/Data_Type.hpp>"
        add_include_for type

        @body << "template<>"
        @body << "Rice::Object to_ruby<#{full_name} >(#{full_name} const & a) {"
        @body << "\treturn Rice::Data_Object<#{full_name} >(#{class_type}, Rice::Data_Type<#{full_name} >::klass(), 0, 0);"
        @body << "}"

        @prototypes << "template<>"
        @prototypes << "Rice::Object to_ruby<#{full_name} >(#{full_name} const & a);"
      end

    end
  end
end
