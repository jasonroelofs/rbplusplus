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
      _Mod.rb.cpp
      _Mod.rb.hpp
      _classes_Adder.rb.cpp
      _classes_Adder.rb.hpp
      adder.rb.cpp
    ).each do |wants|
      assert_not_nil files.find {|got| File.basename(got) == wants }, "Didn't find #{wants}"
    end
  end

end

context "Multiple file writer with to_from_ruby" do

  setup do
    @working_dir = File.expand_path(File.dirname(__FILE__) + "/generated")

    e = Extension.new "to_from_ruby"
    e.working_dir = @working_dir
    e.sources full_dir("headers/to_from_ruby.h"),
      :include_paths => full_dir("headers"),
      :include_source_files => full_dir("headers/to_from_ruby_source.cpp")

    e.namespace "to_from_ruby"

    e.build
    e.write
  end

  specify "should have proper written out files" do
    files = Dir["#{@working_dir}/*"]

    %w(
      extconf.rb
      _to_from_ruby.rb.hpp
      _to_from_ruby.rb.cpp
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

context "Single file writer with to_from_ruby" do

  setup do
    Extension.new "to_from_ruby" do |e|
      e.sources full_dir("headers/to_from_ruby.h"),
        :include_paths => full_dir("headers"),
        :include_source_files => full_dir("headers/to_from_ruby_source.cpp")
      e.namespace "to_from_ruby"

      e.writer_mode :single
    end

  end

  specify "should have compiled properly" do
    should.not.raise LoadError do
      require 'to_from_ruby'
    end
  end
end
