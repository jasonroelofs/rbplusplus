require File.dirname(__FILE__) + '/test_helper'

context "Compiler settings" do

  specify "should be able to specify include paths" do
    Extension.new "compiler" do |e|
      e.sources full_dir("headers/with_includes.h"), 
        :include_paths => full_dir("headers/include")
      e.namespace "code"
    end

    require 'compiler'

    assert defined?(func)
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

    contents.should.match(%r(-L/usr/lib/testing/123))

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

    contents.should.match(%r(-L/usr/lib/testing/456))
    contents.should.match(%r(-L/var/lib/stuff))
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

    contents.should.match(%r(-llib123))
    
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

    contents.should.match(%r(-lponzor))
    contents.should.match(%r(-lwonko))
    contents.should.match(%r(-lprankit))
  end

  xspecify "should be able to use various mkmf methods" do

  end
end
