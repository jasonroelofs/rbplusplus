module RbPlusPlus
  module Writers
    # Writer that takes a builder and writes out the code in
    # one single file
    class SingleFileWriter < Base

      def write
        process_code(builder)
        builder.write

#        if Builders::TypesManager.prototypes.length > 0
#          builder.declarations << Builders::TypesManager.prototypes
#        end
#
#        if Builders::TypesManager.body.length > 0
#          # Handle to_from_ruby constructions
#          builder.declarations << Builders::TypesManager.body
#        end

        filename = builder.name
        cpp_file = File.join(working_dir, "#{filename}.rb.cpp")

        File.open(cpp_file, "w+") do |cpp|
          cpp.puts builder.includes.flatten.uniq.join("\n")
          cpp.puts builder.declarations.flatten.join("\n")
          cpp.puts builder.registrations.flatten.join("\n")
        end
      end

      protected

      # What we do here is to go through the builder heirarchy
      # and push all the code from children up to the parent, 
      # ending up with all the code in the top-level builder
      def process_code(builder)
        if builder.has_children?
          builder.nodes.each do |b|
            process_code(b)
          end
        end

        return unless builder.parent

        builder.write
        builder.parent.includes << builder.includes
        builder.parent.declarations << builder.declarations
        builder.parent.registrations << builder.registrations
      end

    end
  end
end
