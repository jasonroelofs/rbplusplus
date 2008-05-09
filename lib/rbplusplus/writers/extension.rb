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
        inc_str += " " + @cxxflags.join(" ")
        lib_path_str = @library_paths.flatten.uniq.map {|i| "-L#{i}"}.join(" ")
        lib_str = @libraries.flatten.uniq.map {|i| "-l#{i}"}.join(" ")
        lib_str += " " + @ldflags.join(" ")

        File.open(extconf, "w+") do |file|
          file.puts "require \"rubygems\""
          file.puts "require \"mkmf-rice\""
          file.puts %Q($CPPFLAGS = $CPPFLAGS + " -I#{working_dir} #{inc_str}")
          file.puts %Q($LDFLAGS = $LDFLAGS + " #{lib_path_str} #{lib_str}")
          file.puts "create_makefile(\"#{builder.name}\")"
        end
      end

    end
  end
end
