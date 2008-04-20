require File.dirname(__FILE__) + '/test_helper'

context "Ruby Extension creation" do

  specify "should create a valid Ruby extension" do
    Extension.new "ext_test" do |e|
      e.sources full_dir("headers/empty.h")
    end

    should.not.raise LoadError do
      require("ext_test")
    end
  end

  specify "should create a valid Ruby extension without a block" do
    e = Extension.new "extension"
    e.sources full_dir("headers/empty.h")
    e.working_dir = File.join(File.expand_path(File.dirname(__FILE__)), "generated")
    e.build
    e.write
    e.compile

    should.not.raise LoadError do
      require("ext_test")
    end
  end

  specify "should properly build working dir as deep as needed" do
    should.not.raise Errno::ENOENT do
      Extension.new "extension" do |e|
        e.sources full_dir("headers/empty.h")
        e.working_dir = File.join(File.expand_path(File.dirname(__FILE__)), 
                                  "generated", "path1", "path2")
      end
    end
  end
end

