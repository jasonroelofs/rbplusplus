require 'optparse'

module RbPlusPlus

  # This is the starting class for Rb++ wrapping. All Rb++ projects start as such:
  #   
  #   Extension.new "extension_name" do |e|
  #     ...
  #   end
  #
  # where "extension_name" is what the resulting Ruby library will be named.
  #
  # For most cases, the block format will work. If you need more detailed control
  # over the code generation process, you can use an immediate mode:
  #
  #   e = Extension.new "extension_name"
  #   ...
  #
  # The following calls are required in both formats:
  #
  #   e.sources - The directory / array / name of C++ header files to parse. 
  #   
  # In the non-block format, the following calls are required:
  #
  #   e.working_dir - Specify the directory where the code will be generated. This needs
  #   to be a full path.
  #
  # In immediate mode, you must to manually fire the different steps of the
  # code generation process in this order:
  #
  #   e.build - Fires the code generation process
  #
  #   e.write - Writes out the generated code into files
  #
  #   e.compile - Compiles the generated code into a Ruby extension. 
  #   
  class Extension

    # Where will the generated code be put
    attr_accessor :working_dir

    # The list of modules to create
    attr_accessor :modules

    # Various options given by the user to help with
    # parsing, linking, compiling, etc.
    #
    # See #sources for a list of the possible options 
    attr_accessor :options

    # Create a new Ruby extension with a given name. This name will be
    # the actual name of the extension, e.g. you'll have name.so and you will
    # call require 'name' when using your new extension.
    #
    # This constructor can be standalone or take a block. 
    def initialize(name, &block)
      @name = name
      @modules = []
      @writer_mode = :multiple
      @requesting_console = false
      @force_rebuild = false

      @options = {
        :include_paths => [],
        :library_paths => [],
        :libraries => [],
        :cxxflags => [],
        :ldflags => [],
        :include_source_files => [],
        :includes => []
      }

      @node = nil

      parse_command_line

      if requesting_console?
        block.call(self) if block
        start_console
      elsif block
        build_working_dir(&block)
        block.call(self)
        build
        write
        compile
      end
    end

    # Define where we can find the header files to parse
    # Can give an array of directories, a glob, or just a string.
    # All file names should be full paths, not relative.
    #
    # Options can be any or all of the following:
    #
    # * <tt>:include_paths</tt> - Path(s) to be added as -I flags
    # * <tt>:library_paths</tt> - Path(s) to be added as -L flags
    # * <tt>:libraries</tt> - Path(s) to be added as -l flags
    # * <tt>:cxxflags</tt> - Flag(s) to be added to command line for parsing / compiling
    # * <tt>:ldflags</tt> - Flag(s) to be added to command line for linking
    # * <tt>:includes</tt> -  Header file(s) to include at the beginning of each .rb.cpp file generated.
    # * <tt>:include_source_files</tt> - C++ source files that need to be compiled into the extension but not wrapped.
    # * <tt>:include_source_dir</tt> - A combination option for reducing duplication, this option will 
    #   query the given directory for source files, adding all to <tt>:include_source_files</tt> and 
    #   adding all h/hpp files to <tt>:includes</tt> 
    #
    def sources(dirs, options = {})
      parser_options = {}

      if (code_dir = options.delete(:include_source_dir)) 
        options[:include_source_files] ||= []
        options[:includes] ||= []
        Dir["#{code_dir}/*"].each do |f|
          next if File.directory?(f)

          options[:include_source_files] << f
        end
      end

      if (paths = options.delete(:include_paths))
        @options[:include_paths] << paths
        parser_options[:includes] = paths
      end

      if (lib_paths = options.delete(:library_paths))
        @options[:library_paths] << lib_paths 
      end

      if (libs = options.delete(:libraries))
        @options[:libraries] << libs
      end

      if (flags = options.delete(:cxxflags))
        @options[:cxxflags] << flags
        parser_options[:cxxflags] = flags
      end

      if (flags = options.delete(:ldflags))
        @options[:ldflags] << flags
      end

      if (files = options.delete(:include_source_files))
        @options[:include_source_files] << files
        options[:includes] ||= []

        [files].flatten.each do |f|
          options[:includes] << f if File.extname(f) =~ /hpp/i || File.extname(f) =~ /h/i
        end
      end
      
      if (flags = options.delete(:includes))
        includes = Dir.glob(flags)
        if(includes.length == 0)
          puts "Warning: There were no matches for includes #{flags.inspect}"
        else
          @options[:includes] += [*includes]
        end
      end

      @options[:includes] += [*dirs]

      @sources = Dir.glob dirs
      Logger.info "Parsing #{@sources.inspect}"
      @parser = RbGCCXML.parse(dirs, parser_options)
    end

    # Set a namespace to be the main namespace used for this extension.
    # Specifing a namespace on the Extension itself will mark functions,
    # class, enums, etc to be globally available to Ruby (aka not in it's own
    # module)
    #
    # To get access to the underlying RbGCCXML query system, save the
    # return value of this method:
    #
    #   node = namespace "lib::to_wrap"
    #
    def namespace(name)
      @node = @parser.namespaces(name)
    end

    # Mark that this extension needs to create a Ruby module of
    # a give name. Like Extension.new, this can be used with or without
    # a block.
    def module(name, &block)
      m = RbModule.new(name, @parser, &block)
      @modules << m
      m
    end

    # Specify the mode with which to write out code files. This can be one of two modes:
    #
    # * <tt>:multiple</tt> (default) - Each class and module gets it's own set of hpp/cpp files
    # * <tt>:single</tt> - Everything gets written to a single file
    #
    def writer_mode(mode)
      raise "Unknown writer mode #{mode}" unless [:multiple, :single].include?(mode)
      @writer_mode = mode
    end
    
    # Start the code generation process. 
    def build
      raise ConfigurationError.new("Must specify working directory") unless @working_dir
      raise ConfigurationError.new("Must specify which sources to wrap") unless @parser

      Logger.info "Beginning code generation"

      @builder = Builders::ExtensionNode.new(@name, @node || @parser, @modules)
      @builder.add_includes @options[:includes]
      @builder.build
      @builder.sort

      Logger.info "Code generation complete"
    end

    # Write out the generated code into files.
    # #build must be called before this step or nothing will be written out
    def write
      Logger.info "Writing code to files"
      prepare_working_dir
      process_other_source_files
      
      # Create the code
      writer_class = @writer_mode == :multiple ? Writers::MultipleFilesWriter : Writers::SingleFileWriter
      writer_class.new(@builder, @working_dir).write

      # Create the extconf.rb
      extconf = Writers::ExtensionWriter.new(@builder, @working_dir)
      extconf.options = @options
      extconf.write
      Logger.info "Files written"
    end

    # Compile the extension.
    # This will create an rbpp_compile.log file in +working_dir+. View this
    # file to see the full compilation process including any compiler
    # errors / warnings.
    def compile
      Logger.info "Compiling. See rbpp_compile.log for details."
      require 'rbconfig'
      ruby = File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["RUBY_INSTALL_NAME"])
      FileUtils.cd @working_dir do
        system("#{ruby} extconf.rb > rbpp_compile.log 2>&1")
        system("rm -f *.so")
        system("make >> rbpp_compile.log 2>&1")
      end
      Logger.info "Compilation complete."
    end

    protected

    # Read any command line arguments and process them
    def parse_command_line
      OptionParser.new do |opts|
        opts.banner = "Usage: ruby #{$0} [options]"

        opts.on_head("-h", "--help", "Show this help message") do
          puts opts
          exit
        end

        opts.on("-v", "--verbose", "Show all progress messages (INFO, DEBUG, WARNING, ERROR)") do 
          Logger.verbose = true
        end

        opts.on("-q", "--quiet", "Only show WARNING and ERROR messages") do
          Logger.quiet = true
        end

        opts.on("--console", "Open up a console to query the source via rbgccxml") do
          @requesting_console = true
        end

        opts.on("--clean", "Force a complete clean and rebuild of this extension") do
          @force_rebuild = true
        end

      end.parse!
    end

    # Check ARGV to see if someone asked for "console"
    def requesting_console?
      @requesting_console
    end

    # Start up a new IRB console session giving the user access
    # to the RbGCCXML parser instance to do real-time querying
    # of the code they're trying to wrap
    def start_console
      puts "IRB Session starting. @parser is now available to you for querying your code. The extension object is available as 'self'"
      IRB.start_session(binding)
    end

    # If the working dir doesn't exist, make it
    # and if it does exist, clean it out
    def prepare_working_dir
      FileUtils.mkdir_p @working_dir unless File.directory?(@working_dir)
      FileUtils.rm_rf Dir["#{@working_dir}/*"] if @force_rebuild
    end

    # Make sure that any files or globs of files in :include_source_files are copied into the working
    # directory before compilation
    def process_other_source_files
      files = @options[:include_source_files].flatten
      files.each do |f|
        FileUtils.cp Dir[f], @working_dir
      end
    end

    # Cool little eval / binding hack, from need.rb
    def build_working_dir(&block)
      file_name = 
        if block.respond_to?(:source_location)
          block.source_location[0]
        else
          eval("__FILE__", block.binding)
        end

      @working_dir = File.expand_path(
        File.join(File.dirname(file_name), "generated"))
    end
  end
end

require 'irb'

module IRB # :nodoc:
  def self.start_session(binding)
    unless @__initialized
      args = ARGV
      ARGV.replace(ARGV.dup)
      IRB.setup(nil)
      ARGV.replace(args)
      @__initialized = true
    end
    
    workspace = WorkSpace.new(binding)

    irb = Irb.new(workspace)

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end

