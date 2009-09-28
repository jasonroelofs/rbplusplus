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
        @allocations = []
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

        # It has to be a publically accessible type
        return unless type.public?

        full_name = type.qualified_name

        # Only wrap once
        # TODO cleaner way of doing this
        return if @consts_wrapped.include?(full_name)

        # Some types are already handled by Rice, ignore such types
        return if full_name =~ /std::string/

        Logger.info "Creating converter for #{type.qualified_name}"

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

      # If we find classes that have non-public default constructors and / or a non-public
      # destructor, we need to tell Rice that allocation / deallocation for this class is
      # different.
      def build_allocation_strategies(node)
        node_name = node.qualified_name

        return if @allocations.include?(node_name)

        # Due to the nature of GCC-XML's handling of templated classes, there are some
        # classes that might not have any gcc-generated constructors or destructors.
        # We check here if we're one of those classes and completely skip this step
        return if [node.constructors].flatten.empty?

        # Find our public default constructor
        found = node.constructors.find(:arguments => [], :access => "public")
        has_public_constructor = found.is_a?(Array) ? !found.empty? : !found.nil?

        # See if the destructor is public
        has_public_destructor = node.destructor && node.destructor.public?

        # If we've got both, we don't do anything
        return if has_public_constructor && has_public_destructor

        @includes << "#include <rice/Allocation_Strategies.hpp>"
        add_include_for(node)

        @prototypes << "namespace Rice {"
        @prototypes << "\ttemplate<>"
        @prototypes << "\tstruct Default_Allocation_Strategy< #{node_name} > {"
        @prototypes << "\t\tstatic #{node_name} * allocate();"
        @prototypes << "\t\tstatic void free(#{node_name} * obj);"
        @prototypes << "\t};"
        @prototypes << "}"

        pre = "Rice::Default_Allocation_Strategy< #{node_name} >::"

        if has_public_constructor
          @body << "#{node_name} * #{pre}allocate() { return new #{node_name}; }"
        else
          @body << "#{node_name} * #{pre}allocate() { return NULL; }"
        end

        if has_public_destructor
          @body << "void #{pre}free(#{node_name} * obj) { delete obj; }"
        else
          @body << "void #{pre}free(#{node_name} * obj) { }"
        end

        @allocations << node_name
      end
    end
  end
end
