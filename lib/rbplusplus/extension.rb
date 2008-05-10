module RbPlusPlus

  # This is the starting class for Rb++ wrapping. All Rb++ projects start with this
  # class:
  #   
  #   Extension.new "extension_name" do |e|
  #     ...
  #   end
  #
  # "extension_name" is what the resulting Ruby library will be named, aka in your code
  # you will have
  #
  #   require "extension_name"
  #
  # It is recommended that you use the block format of this class's initializer.
  # If you want more fine-grained control of the whole process, don't use
  # the block format. Instead you should do the following:
  #
  #   e = Extension.new "extension_name"
  #   ...
  #
  # The following calls are required in both formats:
  #
  #   #sources - The directory / array / name of C++ header files to parse. 
  #   
  # In the non-block format, the following calls are required:
  #
  #   #working_dir - Specify the directory where the code will be generated. This needs
  #   to be a full path.
  #
  # In the non-block format, you need to manually fire the different steps of the
  # code generation process, and in this order:
  #
  #   #build - Fires the code generation process
  #
  #   #write - Writes out the generated code into files
  #
  #   #compile - Compiles the generated code into a Ruby extension. 
  #   
  class Extension

    # Where will the generated code be put
    attr_accessor :working_dir

    # The list of modules to create
    attr_accessor :modules

    # List of extra include directives
    attr_accessor :includes

    # List of directories for library searching
    attr_accessor :lib_paths

    # List of libraries to link
    attr_accessor :libraries

    # Create a new Ruby extension with a given name. This name will be
    # the module built into the extension. 
    # This constructor can be standalone or take a block. 
    def initialize(name, &block)
      @name = name
      @modules = []
      @writer_mode = :multiple
      @includes = []
      @lib_paths = []
      @libraries = []
      
      NodeCache.instance.clear

      if block
        build_working_dir(&block)
        block.call(self)
        build
        write
        compile
      end
    end

    # Define where we can find the header files to parse
    # Can give an array of directories, a glob, or just a string.
    # All file names should be full paths, not partial.
    #
    # Options can be the following:
    #
    # * <tt>:include_paths</tt> - An array or string of full paths to be added as -I flags
    # * <tt>:library_paths</tt> - An array or string of full paths to be added as -L flags
    # * <tt>:libraries</tt> - An array or string of full paths to be added as -l flags
    def sources(dirs, options = {})
      parser_options = {}

      if (paths = options.delete(:include_paths))
        @includes << paths
        parser_options[:includes] = @includes
      end

      if (lib_paths = options.delete(:library_paths))
        @lib_paths << lib_paths 
      end

      if (libs = options.delete(:libraries))
        @libraries << libs
      end
    
      @sources = Dir.glob dirs
      @parser = RbGCCXML.parse(dirs, parser_options)
    end

    # Set a namespace to be the main namespace used for this extension.
    # Specifing a namespace on the Extension itself will mark functions,
    # class, enums, etc to be globally available to Ruby (aka not in it's own
    # module)
    def namespace(name)
      @node = @parser.namespaces(name)
    end

    # Mark that this extension needs to create a Ruby module of
    # a give name. Like Extension, this can be used with or without
    # a block.
    def module(name, &block)
      m = RbModule.new(name, @parser, &block)
      @modules << m
      m
    end

    # How should we write out the source code? This can be one of two modes:
    # * <tt>:multiple</tt> (default) - Each class and module gets it's own set of hpp/cpp files
    # * <tt>:single</tt> - Everything gets written to a single file
    def writer_mode(mode)
      raise "Unknown writer mode #{mode}" unless [:multiple, :single].include?(mode)
      @writer_mode = mode
    end
    
    # Start the code generation process. 
    def build
      raise ConfigurationError.new("Must specify working directory") unless @working_dir
      raise ConfigurationError.new("Must specify which sources to wrap") unless @parser

      @builder = Builders::ExtensionBuilder.new(@name, @sources, @node || @parser)
      @builder.modules = @modules
      @builder.build
    end

    # Write out the generated code into files.
    # #build must be called before this step or nothing will be written out
    def write
      prepare_working_dir
      
      # Create the code
      writer_class = @writer_mode == :multiple ? Writers::MultipleFilesWriter : Writers::SingleFileWriter
      writer_class.new(@builder, @working_dir).write

      # Create the extconf.rb
      extconf = Writers::ExtensionWriter.new(@builder, @working_dir)
      extconf.includes = @includes
      extconf.library_paths = @lib_paths
      extconf.libraries = @libraries
      extconf.write
    end

    # Compile the extension.
    # This will create an rbpp_compile.log file in @working_dir. View this
    # file to see the full compilation process including any compiler
    # errors / warnings.
    def compile
      FileUtils.cd @working_dir do
        system("ruby extconf.rb > rbpp_compile.log 2>&1")
        system("make >> rbpp_compile.log 2>&1")
      end
    end

    protected

    # If the working dir doesn't exist, make it
    # and if it does exist, clean it out
    def prepare_working_dir
      FileUtils.mkdir_p @working_dir unless File.directory?(@working_dir)
      FileUtils.rm_rf "#{@working_dir}/*"
    end

    # Cool little eval / binding hack, from need.rb
    def build_working_dir(&block)
      @working_dir = File.expand_path(
        File.join(File.dirname(eval("__FILE__", block.binding)), "generated"))
    end
  end
end
