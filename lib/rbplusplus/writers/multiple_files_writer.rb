module RbPlusPlus
  module Writers
    # Writer that takes a builder and writes out the code in
    # multiple files.
    class MultipleFilesWriter < Base

      # Writing out a multiple-file built is a multi-stage process. This writer
      # first builds a [working_dir]/.build directory, where new code initially goes.
      # Once the writing is complete, each file in .build/ is diff-checked by the files
      # in [working_dir]. If the files are different, the new file is copied into place.
      # Then, the .build dir is removed.
      #
      # We do this to allow for easy and quick-ish work on large wrapping projects. Because
      # Rice code takes so long to compile, the fewer files one has to compile per change
      # the better.
      def write
        build_working_dir
        write_files
        process_diffs
        cleanup
      end

      private

      def build_working_dir
        @build_dir = File.join(working_dir, ".build")

        # Build our temp dir
        FileUtils.mkdir_p @build_dir
      end

      # Go through each file in @build_dir and check them against
      # the files in @working_dir, copying over only the ones
      # that differ
      def process_diffs
        Dir["#{@build_dir}/*.{cpp,hpp}"].each do |file|
          FileUtils.cp file, working_dir if files_differ(file)
        end
      end

      def files_differ(file)
        filename = File.basename(file)
        existing = File.expand_path(File.join(working_dir, filename))
        new = File.expand_path(File.join(@build_dir, filename))
        return true if !File.exists?(existing)

        !system("diff #{existing} #{new} > #{@build_dir}/diff_info 2>&1")
      end

      def cleanup
        FileUtils.rm_rf @build_dir
      end

      # Given our builder, go through nodes and write out files
      def write_files
        # Couple of steps here:
        #  - Split up the code into files according to Modules and Classes
        #  - Header files need a register_#{name} prototype, source needs
        #    register_#{name}(#{parent}) method definition
        #  - All includes for this node go in the header.
        #  - Source gets an include for the related header
        #  - Save up all data from global_children and at the end write out
        #    our rbpp_custom files, making sure all header files include
        #    rbpp_custom.hpp

        @file_writers = []
        @global_writer = RbppCustomFileWriter.new
        @globals_handled = []

        new_file_for(self.builder)
        process_globals(self.builder)

        @global_writer.with_includes(self.builder.additional_includes)
        @global_writer.write(@build_dir)

        # Write out from the bottom up, makes sure that children file writers
        # update their parents as needed
        @file_writers.each do |fw|
          fw.write(@build_dir, self.builder.additional_includes)
        end
      end

      def process_globals(node)
        # Process the globals
        node.global_nodes.each do |g|
          next if @globals_handled.include?(g.qualified_name)
          @globals_handled << g.qualified_name
          @global_writer << g
        end

        node.nodes.each do |b|
          process_globals(b)
        end
      end

      def new_file_for(node, parent = nil)
        file_writer = FileWriter.new(node, parent)
        @file_writers << file_writer

        process_file(file_writer, node)
      end

      # Recursively run through this node's children
      # adding them to the given file_writer or spawning
      # off another file writer depending on the type
      # of node we hit
      def process_file(file_writer, node)
        node.nodes.each do |child|
          if child.is_a?(Builders::ModuleNode) || child.is_a?(Builders::ClassNode)
            new_file_for(child, file_writer)
          else
            file_writer << child
            process_file(file_writer, child) if child.has_children?
          end
        end
      end

      # For every file to write out, we build an instance of a FileWriter here.
      # This class needs to be given all the nodes it will be writing out to a file
      #
      # To handle parents calling register_#{name}() on their children, it's up to the
      # children writers to inform the parents of their existence
      class FileWriter

        attr_reader :base_name, :node

        def initialize(node, parent)
          @node = node
          @base_name = node.qualified_name.as_variable

          @register_method = nil
          @register_methods = []
          @register_includes = []


          @header = parent ? "_#{@base_name}.rb.hpp" : nil
          @source = parent ? "_#{@base_name}.rb.cpp" : "#{@base_name}.rb.cpp"
          @parent = parent

          @require_custom = false

          @needs_closing = true

          register_with_parent if @parent

          @nodes = [@node]
        end

        # Add a node to this file writer
        def <<(node)
          @nodes << node
        end

        def write(build_dir, custom_includes = [])
          @build_dir = build_dir
          @custom_includes = custom_includes.flatten

          build_source
          write_header if @header
          write_source
        end

        def rice_type
          @node.rice_variable_type
        end

        def rice_variable
          @node.rice_variable
        end

        def has_rice_variable?
          !@node.rice_variable.nil?
        end

        def add_register_method(node_name, header)
          @register_includes << "#include \"#{header}\""
          @register_methods << "register_#{node_name}(#{has_rice_variable? ? self.rice_variable : ""});"
        end

        protected

        def register_with_parent
          @register_method = "void register_#{@base_name}"
          @parent.add_register_method @base_name, @header
        end

        def build_source
          @includes = []
          @declarations = []
          @registrations = []

          @nodes.each do |node|
            node.write
            @includes << node.includes
            @declarations << node.declarations
            @registrations << node.registrations
          end
        end

        def parent_signature
          if @parent && @parent.has_rice_variable?
            "#{@parent.rice_type} #{@parent.rice_variable}"
          else
            ""
          end
        end

        def write_header
          include_guard = "__RICE_GENERATED_#{@base_name}_HPP__"

          File.open(File.join(@build_dir, @header), "w+") do |hpp|
            hpp.puts "#ifndef #{include_guard}"
            hpp.puts "#define #{include_guard}"
            hpp.puts

            custom_name = "_rbpp_custom.rb.hpp"
            hpp.puts "#include \"#{custom_name}\"" if File.exists?(File.join(@build_dir, custom_name))

            if @register_method
              hpp.puts "#{@register_method}(#{parent_signature});"
            end

            hpp.puts
            hpp.puts "#endif // #{include_guard}"
          end
        end

        def write_source
          File.open(File.join(@build_dir, @source), "w+") do |cpp|
            if (incls = @includes.flatten.compact).any?
              incl_output = incls.uniq.sort.reverse.join("\n")
              cpp.puts "", incl_output, ""
            end

            @custom_includes.each do |incl|
              cpp.puts "#include \"#{incl}\"" unless incl_output =~ %r{#{incl}}
            end

            if @register_method
              cpp.puts "", "#include \"#{@header}\"", ""
            end

            if @require_custom
              custom_name = "_rbpp_custom.rb.hpp"
              cpp.puts "#include \"#{custom_name}\"" if File.exists?(File.join(@build_dir, custom_name))
            end

            if @register_includes
              @register_includes.each do |i|
                cpp.puts i
              end
            end

            if (decls = @declarations.flatten.compact).any?
              cpp.puts "", decls.join("\n"), ""
            end

            if @register_method
              cpp.puts "#{@register_method}(#{parent_signature}) {"
            end

            if @register_methods
              # Ug, hack. I've seriously got to rethink this whole
              # code generation system ... again
              @register_methods.reverse.each do |reg|
                @registrations.insert(3, reg)
              end
            end

            if (regs = @registrations.flatten.compact).any?
              cpp.puts regs.join("\n")
            end

            # I really need a better way of handling this
            if @needs_closing
              cpp.puts "} RUBY_CATCH" unless @parent
              cpp.puts "}"
            end
          end
        end

      end

      class RbppCustomFileWriter < FileWriter

        def initialize
          @base_name = "rbpp_custom"
          @header = "_#{@base_name}.rb.hpp"
          @source = "_#{@base_name}.rb.cpp"
          @nodes = []
          @needs_closing = false
          @additional_includes = []
          @require_custom = true

          @register_method = nil
          @register_includes = []
          @register_methods = []
        end

        def with_includes(includes)
          @additional_includes =
            includes.flatten.inject([]) do |memo, incl|
              memo << "#include \"#{incl}\""; memo
            end
        end

        protected

        def write_header
          return unless @registrations.flatten.compact.any?

          include_guard = "__RICE_GENERATED_#{@base_name}_HPP__"

          File.open(File.join(@build_dir, @header), "w+") do |hpp|
            hpp.puts "#ifndef #{include_guard}"
            hpp.puts "#define #{include_guard}"

            if (incls = [@includes, @additional_includes].flatten.compact).any?
              hpp.puts "", incls.uniq.sort.reverse.join("\n"), ""
            end

            if (decls = @declarations.flatten.compact).any?
              hpp.puts "", decls.join("\n"), ""
            end
            hpp.puts
            hpp.puts "#endif // #{include_guard}"
          end

          @declarations = []
          @includes = []
        end

        def write_source
          super if @registrations.flatten.compact.any?
        end

      end

    end
  end
end
