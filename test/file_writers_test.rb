require File.dirname(__FILE__) + '/test_helper'

context "Multiple file writer (default)" do

  setup do
    @working_dir = File.expand_path(File.dirname(__FILE__) + "/generated")

    e = Extension.new "adder"
    e.working_dir = @working_dir
    e.sources full_dir("headers/Adder.h")

    e.module "Mod" do |m|
      m.namespace "classes"
    end

    e.build
    e.write
  end

  specify "should properly split up code into multiple files" do
    files = Dir["#{@working_dir}/*"]
    files.size.should == 6

    %w(
      extconf.rb
      Mod.rb.cpp
      Mod.rb.hpp
      classes_Adder.rb.cpp
      classes_Adder.rb.hpp
      adder.rb.cpp
    ).each do |wants|
      assert_not_nil files.find {|got| File.basename(got) == wants }, "Didn't find #{wants}"
    end
  end

end

context "Single file writer" do

  setup do
    @working_dir = File.expand_path(File.dirname(__FILE__) + "/generated")

    e = Extension.new "adder"
    e.working_dir = @working_dir
    e.sources full_dir("headers/Adder.h")
    e.writer_mode :single

    e.module "Mod" do |m|
      m.namespace "classes"
    end

    e.build
    e.write
  end

  specify "should properly write out all code in a single file" do
    files = Dir["#{@working_dir}/*"]
    files.size.should == 2

    %w(
      extconf.rb
      adder.rb.cpp
    ).each do |wants|
      assert_not_nil files.find {|got| File.basename(got) == wants }, "Didn't find #{wants}"
    end
  end

end
