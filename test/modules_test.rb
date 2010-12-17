require 'test_helper'

describe "Extension with modules" do

  before(:all) do
    Extension.new "modules" do |e|
      e.sources [
          full_dir("headers/Adder.h"),
          full_dir("headers/functions.h"),
          full_dir("headers/Subtracter.hpp")
        ],
        :include_source_files => [
          full_dir("headers/Adder.h"),
          full_dir("headers/Adder.cpp")
        ]

      e.writer_mode :single

      e.module "Empty" do |m|
      end

      # Can use without a block
      wrapper = e.module "Wrapper"
      node = wrapper.namespace "classes"
      node.classes("Adder").disable_typedef_lookup

      e.module "Functions" do |m|
        m.namespace "functions"
      end

      e.module "Nested" do |m|
        m.module "Nested" do |n|
          n.module "Inner" do |inner|
            inner.namespace "subtracter"
          end
        end
      end

    end

    require 'modules'
  end

  specify "should be able to generate a module definition" do
    lambda { Empty }.should_not raise_error(NameError)

    Empty.class.should == Module
  end

  specify "should wrap up C++ classes under the namespace as requested" do
    lambda { Adder }.should raise_error(NameError)
    lambda { Wrapper::Adder }.should_not raise_error(NameError)

    a = Wrapper::Adder.new
    a.get_class_name.should == "Adder"
  end

  specify "should wrap up C++ functions in the module" do
    lambda { Functions }.should_not raise_error(NameError)
    Functions::test2(2).should be_within(0.001).of(1.0)
    Functions::test3(4, 6).should == 4
  end

  specify "should be able to nest modules and related definitions" do
    lambda { Subtracter }.should raise_error(NameError)
    lambda { Nested::Nested::Inner::Subtracter }.should_not raise_error(NameError)

    s = Nested::Nested::Inner::Subtracter.new
    s.get_class_name.should == "Subtracter"
  end
end
