require 'test_helper'

describe "Ruby Extension creation" do

  specify "should create a valid Ruby extension" do
    Extension.new "ext_test" do |e|
      e.sources full_dir("headers/empty.h")
      e.writer_mode :single
    end

    lambda do
      require "ext_test"
    end.should_not raise_error(LoadError)
  end

  specify "should create a valid Ruby extension without a block" do
    e = Extension.new "extension"
    e.sources full_dir("headers/empty.h")
    e.working_dir = File.join(File.expand_path(File.dirname(__FILE__)), "generated")
    e.writer_mode :single
    e.build
    e.write
    e.compile

    lambda do
      require "ext_test"
    end.should_not raise_error(LoadError)
  end

  specify "should properly build working dir as deep as needed" do
    lambda do
      path = File.join(File.expand_path(File.dirname(__FILE__)), "generated", "path1", "path2")
      Extension.new "extension" do |e|
        e.sources full_dir("headers/empty.h")
        e.working_dir = path
        e.writer_mode :single
      end

      File.exists?(File.join(path, "extconf.rb")).should be_true
    end.should_not raise_error(Errno::ENOENT)
  end
end

