require File.dirname(__FILE__) + '/test_helper'

context "Wrapping Classes within classes" do
  def setup
    if !defined?(@@nested_built)
      super
      @@nested_built = true 
      Extension.new "nested" do |e|
        e.sources full_dir("headers/nested_classes.h")
        node = e.namespace "classes"
      end

      require 'nested'
    end
  end

  specify "should properly make nested classes available" do
    assert defined?(TestClass) 
    assert defined?(TestClass::InnerClass) 
    assert defined?(TestClass::InnerClass::Inner2) 

    TestClass.new.should.not.be.nil
    TestClass::InnerClass.new.should.not.be.nil
    TestClass::InnerClass::Inner2.new.should.not.be.nil
  end
end
