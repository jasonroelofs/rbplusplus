require 'test_helper'

describe "Multiple file writer (default)" do

  before(:each) do
    @working_dir = File.expand_path(File.dirname(__FILE__) + "/generated")

    e = Extension.new "adder"
    e.working_dir = @working_dir
    e.sources full_dir("headers/Adder.h")

    e.module "Mod" do |m|
      node = m.namespace "classes"
      node.classes("Adder").disable_typedef_lookup
    end

    e.build
    e.write
  end

  specify "should properly split up code into multiple files" do
    files = Dir["#{@working_dir}/*"]
    files.size.should == 10

    %w(
      extconf.rb
      _Mod.rb.cpp
      _Mod.rb.hpp
      _classes_Adder.rb.cpp
      _classes_Adder.rb.hpp
      _classes_IntAdder.rb.cpp
      _classes_IntAdder.rb.hpp
      _classes_ShouldFindMe.rb.hpp
      _classes_ShouldFindMe.rb.cpp
      adder.rb.cpp
    ).each do |wants|
      files.find {|got| File.basename(got) == wants }.should_not be_nil
    end
  end

end

describe "Multiple file writer works with global _rbpp_custom" do

  before(:each) do
    @working_dir = File.expand_path(File.dirname(__FILE__) + "/generated")

    e = Extension.new "enums"
    e.working_dir = @working_dir
    e.sources full_dir("headers/enums.h")

    e.namespace "enums"

    e.build
    e.write
  end

  specify "should have proper written out files" do
    files = Dir["#{@working_dir}/*"]

    %w(
      extconf.rb
      _rbpp_custom.rb.hpp
      _rbpp_custom.rb.cpp
    ).each do |wants|
      files.find {|got| File.basename(got) == wants }.should_not be_nil
    end
  end

end

describe "Single file writer" do

  before(:each) do
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
      files.find {|got| File.basename(got) == wants }.should_not be_nil
    end
  end

end

describe "Single file writer with to_from_ruby" do

  before(:each) do
    Extension.new "to_from_ruby" do |e|
      e.sources full_dir("headers/to_from_ruby.h"),
        :include_paths => full_dir("headers"),
        :include_source_files => full_dir("headers/to_from_ruby_source.cpp")
      e.namespace "to_from_ruby"

      e.writer_mode :single
    end

  end

  specify "should have compiled properly" do
    lambda do
      require 'to_from_ruby'
    end.should_not raise_error(LoadError)
  end
end
