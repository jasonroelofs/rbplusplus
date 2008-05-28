module RbPlusPlus
  module Writers

    # Writes out the code for building the extension.
    # This writer takes care of building the extconf.rb
    # file with the appropriate options.
    class ExtensionWriter < Base

      # Options given from the extension
      attr_accessor :options

      def write
        extconf = File.join(working_dir, "extconf.rb")

        inc_str = @options[:include_paths].flatten.uniq.map {|i| "-I#{i}"}.join(" ")
        inc_str += " " + @options[:cxxflags].flatten.join(" ")
        lib_path_str = @options[:library_paths].flatten.uniq.map {|i| "-L#{i}"}.join(" ")
        lib_str = @options[:libraries].flatten.uniq.map {|i| "-l#{i}"}.join(" ")
        lib_str += " " + @options[:ldflags].flatten.join(" ")

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
