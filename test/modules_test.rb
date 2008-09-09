require File.dirname(__FILE__) + '/test_helper'

context "Extension with modules" do

  def setup
    if !defined?(@@modules_built)
      super
      @@modules_built = true 
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

#        e.writer_mode :single

        e.module "Empty" do |m|
        end

        # Can use without a block
        wrapper = e.module "Wrapper"
        wrapper.namespace "classes"

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
  end

  specify "should be able to generate a module definition" do
    assert defined?(Empty)
    Empty.class.should == Module
  end

  specify "should wrap up C++ classes under the namespace as requested" do
    assert !defined?(Adder)
    assert defined?(Wrapper::Adder)
    a = Wrapper::Adder.new
    a.get_class_name.should == "Adder"
  end

  specify "should wrap up C++ functions in the module" do
    assert defined?(Functions)
    Functions::test2(2).should.be.close 1.0, 0.001
    Functions::test3(4, 6).should == 4
  end

  specify "should be able to nest modules and related definitions" do
    assert !defined?(Subtracter)
    assert defined?(Nested::Nested::Inner::Subtracter)
    s = Nested::Nested::Inner::Subtracter.new
    s.get_class_name.should == "Subtracter"
  end
end
