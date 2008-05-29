module RbPlusPlus
  module Writers
    # Writer that takes a builder and writes out the code in
    # multiple files.
    class MultipleFilesWriter < Base

      def write
        @to_from_include = ""
        write_to_from_ruby
        _write_node(builder)
      end

      # Write out files that include the auto-generated to_/from_ruby constructs.
      def write_to_from_ruby
        # Ignore this if there's nothing to write out
        return if Builders::TypesManager.body.length == 0

        hpp_file = File.join(working_dir, "_to_from_ruby.rb.hpp")
        cpp_file = File.join(working_dir, "_to_from_ruby.rb.cpp")

        @to_from_include = "#include \"#{hpp_file}\""

        include_guard = "__RICE_GENERATED_TO_FROM_RUBY_HPP__"

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
      # We'll recurse through the builder heirarchy, starting at the bottom.
      # This lets us to properly link up each file so that all classes / modules / 
      # functions get properly exposed.
      def _write_node(node)
        node.builders.each do |b|
          _write_node(b)
        end

        filename = if node.parent
                     node.qualified_name.gsub(/::/, "_")
                   else
                     node.name
                   end

        cpp_file = File.join(working_dir, "#{filename}.rb.cpp")

        if node.parent
          hpp_file = File.join(working_dir, "#{filename}.rb.hpp")
          hpp_include = "#include \"#{hpp_file}\""
          register_func = "register_#{filename}"

          include_guard = "__RICE_GENERATED_#{filename}_HPP__"

          register_func_arg = ""
          register_func_prototype = ""

          if !node.parent.is_a?(Builders::ExtensionBuilder)
            register_func_arg = node.parent.rice_variable
            register_func_prototype = "#{node.parent.rice_variable_type} #{register_func_arg}"
          end

          # Changes we need to make to the parent for everything to work across multiple 
          # files
          #
          # * Add an include to the hpp file
          # * Add a call to the register method
          node.parent.includes << hpp_include

          # Bypass the boilerplate code.
          node.parent.body.insert(2, "#{register_func}(#{register_func_arg});")

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

          node.body = [
            "void #{register_func}(#{register_func_prototype}) {",
            node.body,
            "}"
          ]
        end

        File.open(cpp_file, "w+") do |cpp|
          cpp.puts node.to_s
        end
      end


    end
  end
end
