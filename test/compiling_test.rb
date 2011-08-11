require 'test_helper'

describe "Compiler settings" do

  before(:each) do
    test_setup
  end

  specify "should be able to specify include paths" do
    Extension.new "compiler" do |e|
      e.sources full_dir("headers/with_includes.h"), 
        :include_paths => full_dir("headers/include")
      e.namespace "code"
    end

    require 'compiler'

    func(1, 2).should == 3
  end

  specify "should be able to specify library paths" do
    # Single path
    e = Extension.new "libs_test" 
    e.working_dir = full_dir("generated")
    e.sources full_dir("headers/empty.h"),
        :library_paths => "/usr/lib/testing/123"
    e.build
    e.write

    ext_file = full_dir("generated/extconf.rb")

    contents = File.read(ext_file)

    contents.should =~ %r(-L/usr/lib/testing/123)

    # Clean up
    `rm -rf #{full_dir('generated')}/*`

    # Array of paths
    e = Extension.new "libs_test" 
    e.working_dir = full_dir("generated")
    e.sources full_dir("headers/empty.h"),
        :library_paths => ["/usr/lib/testing/456", "/var/lib/stuff"]
    e.build
    e.write

    ext_file = full_dir("generated/extconf.rb")

    contents = File.read(ext_file)

    contents.should =~ %r(-L/usr/lib/testing/456)
    contents.should =~ %r(-L/var/lib/stuff)
  end

  specify "should be able to link to external libraries" do
    # Single library
    e = Extension.new "libs_test" 
    e.working_dir = full_dir("generated")
    e.sources full_dir("headers/empty.h"),
        :libraries => "lib123"
    e.build
    e.write

    ext_file = full_dir("generated/extconf.rb")

    contents = File.read(ext_file)

    contents.should =~ %r(-llib123)
    
    # Clean up
    `rm -rf #{full_dir('generated')}/*`

    # Array of libraries
    e = Extension.new "libs_test" 
    e.working_dir = full_dir("generated")
    e.sources full_dir("headers/empty.h"),
        :libraries => ["ponzor", "wonko", "prankit"]
    e.build
    e.write

    ext_file = full_dir("generated/extconf.rb")

    contents = File.read(ext_file)

    contents.should =~ %r(-lponzor)
    contents.should =~ %r(-lwonko)
    contents.should =~ %r(-lprankit)
  end

  specify "can add extra cxxflags for gccxml and compiling" do
    e = Extension.new "flags_test" 
    e.working_dir = full_dir("generated")
    e.sources full_dir("headers/empty.h"),
      :cxxflags => "-I/i/love/scotch -D__AND_DEFINE_THAT"
    e.build
    e.write

    ext_file = full_dir("generated/extconf.rb")

    contents = File.read(ext_file)

    contents.should =~ %r(-I/i/love/scotch)
    contents.should =~ %r(-D__AND_DEFINE_THAT)
  end

  specify "can add extra ldflags for gccxml and compiling" do
    e = Extension.new "flags_test" 
    e.working_dir = full_dir("generated")
    e.sources full_dir("headers/empty.h"),
      :ldflags => "-R/wootage/to/you -lthisandthat -nothing_here"
    e.build
    e.write

    ext_file = full_dir("generated/extconf.rb")

    contents = File.read(ext_file)

    contents.should =~ %r(-R/wootage/to/you)
    contents.should =~ %r(-lthisandthat)
    contents.should =~ %r(-nothing_here)
  end

  specify "should pass cxxflags to rbgccxml" do
    lambda do
      e = Extension.new "parsing_test" 
      e.working_dir = full_dir("generated")
      e.sources full_dir("headers/requires_define.h"),
        :cxxflags => "-DMUST_BE_DEFINED"
      e.build
      e.write
    end.should_not raise_error
  end

  specify "should be able to add additional headers as needed" do
    lambda do
      e = Extension.new "external" 
      e.working_dir = full_dir("generated")
      e.sources full_dir("headers/external_mapping.h"), 
        :includes => full_dir("headers/*rice.h")
      e.build
      e.write

      file = full_dir("generated/external.rb.cpp")
      contents = File.read(file)
      contents.should =~ %r(headers/external_mapping_rice.h)
    end.should_not raise_error
  end

  specify "can specify other source files to be compiled into the extension" do
    Extension.new "source_files" do |e|
      e.sources full_dir("headers/to_from_ruby.h"),
        :include_paths => full_dir("headers"),
        :include_source_files => full_dir("headers/to_from_ruby_source.cpp")
      e.namespace "to_from_ruby"
    end

    require 'source_files'

    # Don't know if there's any way to catch this nicely. A failure here
    # is a symbol lookup failure and death to the Ruby VM
    needs_to_ruby(3).value.should == 3
  end
end
