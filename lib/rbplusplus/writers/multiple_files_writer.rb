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
        @to_from_include = ""
        @build_dir = File.join(working_dir, ".build")

        # Build our temp dir
        FileUtils.mkdir_p @build_dir

        # Write out files
#        write_to_from_ruby
        _write_node(builder)

        # Done with writing, commence diff checking
        Dir["#{@build_dir}/*.rb.*"].each do |file|
          FileUtils.cp file, working_dir if files_differ(file)
        end

        # Comparison and move done, remove .build
        FileUtils.rm_rf @build_dir
      end

      def files_differ(file)
        filename = File.basename(file)
        existing = File.expand_path(File.join(working_dir, filename))
        new = File.expand_path(File.join(@build_dir, filename))
        return true if !File.exists?(existing)

        !system("diff #{existing} #{new} > #{@build_dir}/diff_info 2>&1")
      end

      # Write out files that include the auto-generated to_/from_ruby constructs.
      def write_to_from_ruby
        # Ignore this if there's nothing to write out
        return if Builders::TypesManager.body.length == 0

        hpp_file = File.join(@build_dir, "_rbpp_custom.rb.hpp")
        cpp_file = File.join(@build_dir, "_rbpp_custom.rb.cpp")

        @to_from_include = "#include \"#{hpp_file.gsub(/\.build\//, "")}\""

        include_guard = "__RICE_GENERATED_RBPP_CUSTOM_HPP__"

        File.open(hpp_file, "w+") do |f|
          f.puts "#ifndef #{include_guard}"
          f.puts "#define #{include_guard}"
          f.puts ""
          f.puts Builders::TypesManager.includes.uniq.join("\n")
          f.puts ""
          f.puts Builders::TypesManager.prototypes.join("\n")
          f.puts ""
          f.puts "#endif // #{include_guard}"
        end

        File.open(cpp_file, "w+") do |f|
          f.puts @to_from_include
          f.puts ""
          f.puts Builders::TypesManager.body.join("\n");
        end
      end

      # How this works:
      #
      # We split code into files at the top-level class and module nodes. 
      # Any nested classes / structs / enums, etc, get wrapped in the same
      # file as the parent class. 
      def _write_node(node)
        node.builders.each do |b|
          if b.is_a?(Builders::ModuleBuilder) ||
            (b.parent.is_a?(Builders::ModuleBuilder) || b.parent.is_a?(Builders::ExtensionBuilder))
            _write_node(b) 
          end
        end

        has_parent = node.parent && !node.parent.is_a?(Builders::ExtensionBuilder)
        is_top = node.is_a?(Builders::ExtensionBuilder)

        filename =
          if node.class_type
            node.class_type
          elsif has_parent && !is_top
            node.qualified_name
          else
            node.name
          end

        # We don't want the top-level extension.rb.cpp file to have an underscore, but
        # all of the rest should have one
        if !is_top
          filename = "_#{filename}"
        end

        filename = filename.functionize

        cpp_file = File.join(@build_dir, "#{filename}.rb.cpp")

        if node.parent
          hpp_file = File.join(@build_dir, "#{filename}.rb.hpp")
          hpp_include = "#include \"#{hpp_file.gsub(/\.build\//, "")}\""
          register_func = "register_#{filename}"

          include_guard = "__RICE_GENERATED_#{filename}_HPP__"

          register_func_arg = ""
          register_func_prototype = ""

          if has_parent
            register_func_arg = node.parent.rice_variable
            register_func_prototype = "#{node.parent.rice_variable_type} #{register_func_arg}"
          end

          # Changes we need to make to the parent for everything to work across multiple
          # files
          #
          # * Add an include to the hpp file
          # * Add a call to the register method
          node.parent.includes << hpp_include

          # Register for proper flattening of the inheritance tree
          node.parent.register_node(node, "#{register_func}(#{register_func_arg});")

          # Modifications to this current node's code:
          #
          # * Add a register prototype to the header file
          # * Set include in node to the header file
          # * Wrap the body in a register method

          File.open(hpp_file, "w+") do |hpp|
            hpp.puts "#ifndef #{include_guard}"
            hpp.puts "#define #{include_guard}"
            hpp.puts ""
            hpp.puts @to_from_include
            hpp.puts ""
            hpp.puts "void #{register_func}(#{register_func_prototype});"
            hpp.puts "#endif"
          end

          node.includes << hpp_include

          node.includes = get_includes_for(node)

          node.declarations = get_decls_for(node)

          node.body = [
            "void #{register_func}(#{register_func_prototype}) {",
            get_body_for(node),
            "}"
          ]
        end

        File.open(cpp_file, "w+") do |cpp|
          cpp.puts node.to_s
        end
      end

      def get_includes_for(node)
        return node.includes if node.is_a?(Builders::ModuleBuilder)

        includes = 
          node.builders.inject([]) do |memo, inner|
            memo << get_includes_for(inner) unless inner.is_a?(Builders::ModuleBuilder)
            memo
          end
        node.includes + includes.flatten
      end

      def get_body_for(node)
        return node.body if node.is_a?(Builders::ModuleBuilder)

        body = 
          node.builders.inject([]) do |memo, inner|
            memo << get_body_for(inner) unless inner.is_a?(Builders::ModuleBuilder)
            memo
          end
        node.body + body.flatten
      end

      def get_decls_for(node)
        return node.declarations if node.is_a?(Builders::ModuleBuilder)

        declarations = 
          node.builders.inject([]) do |memo, inner|
            memo << get_decls_for(inner) unless inner.is_a?(Builders::ModuleBuilder)
            memo
          end
        node.declarations + declarations.flatten
      end

    end
  end
end
