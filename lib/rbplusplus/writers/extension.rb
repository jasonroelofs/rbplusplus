module RbPlusPlus
  module Writers

    # Writes out the code for building the extension.
    # This writer takes care of building the extconf.rb
    # file with the appropriate options.
    class ExtensionWriter < Base

      # List of -I directives
      attr_accessor :includes

      # List of -L directives
      attr_accessor :library_paths

      # List of -l directives
      attr_accessor :libraries

      # Extra CXXFLAGS
      attr_accessor :cxxflags

      # Extra LDFLAGS
      attr_accessor :ldflags

      def write
        extconf = File.join(working_dir, "extconf.rb")

        @includes ||= []

        inc_str = @includes.flatten.uniq.map {|i| "-I#{i}"}.join(" ")
        inc_str += " " + @cxxflags.flatten.join(" ")
        lib_path_str = @library_paths.flatten.uniq.map {|i| "-L#{i}"}.join(" ")
        lib_str = @libraries.flatten.uniq.map {|i| "-l#{i}"}.join(" ")
        lib_str += " " + @ldflags.flatten.join(" ")

        File.open(extconf, "w+") do |file|
          file.puts <<-EOF
          require 'rubygems'
          require 'mkmf-rice'
          
          # Add the arguments to the linker flags.
          def append_ld_flags(flags)
            flags = [flags] unless flags.is_a?(Array)
            with_ldflags("\#{$LDFLAGS} \#{flags.join(' ')}") { true }
          end
          
          $CPPFLAGS += \"-I'#{working_dir}' #{inc_str}\"
          $LDFLAGS += \"#{lib_path_str} #{lib_str}\"
          
          if RUBY_PLATFORM =~ /darwin/
            # In order to link the shared library into our bundle with GCC 4.x on OSX, we have to work around a bug:
            #   GCC redefines symbols - which the -fno-common prohibits.  In order to keep the -fno-common, we
            #   remove the flat_namespace (we now have two namespaces, which fixes the GCC clash).  Also, we now lookup
            #   symbols in both the namespaces (dynamic_lookup).
            $LDSHARED_CXX.gsub!('suppress', 'dynamic_lookup')
            $LDSHARED_CXX.gsub!('-flat_namespace', '')
            
            append_ld_flags '-all_load'
          end
          
          create_makefile(\"#{builder.name}\")
EOF
        end
      end

    end
  end
end
