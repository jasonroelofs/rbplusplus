module RbPlusPlus
  module Builders

    # Handles code generation for to_ruby converters for const& types
    class ConstConverterNode < Base

      def build
      end

      def write
        full_name = self.code.qualified_name

        # Various reasons we don't want to generate this:
        # Rice already handles it
        return if full_name =~ /std::string/

        includes << "#include <rice/Object.hpp>"
        includes << "#include <rice/Data_Object.hpp>"
        includes << "#include <rice/Data_Type.hpp>"

        includes << "#include \"#{self.code.file}\""

        declarations << "template<>"
        declarations << "Rice::Object to_ruby<#{full_name} >(#{full_name} const & a);"

        build_as = if self.parent.is_a?(EnumerationNode)
                     "new #{full_name}(a)"
                   else
                     "(#{full_name} *)&a"
                   end

        registrations << "template<>"
        registrations << "Rice::Object to_ruby<#{full_name} >(#{full_name} const & a) {"
        registrations << "\treturn Rice::Data_Object<#{full_name} >(#{build_as}, Rice::Data_Type<#{full_name} >::klass(), 0, 0);"
        registrations << "}"
      end

    end

  end
end
