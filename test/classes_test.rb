require File.dirname(__FILE__) + '/test_helper'

context "Extension with wrapped classes" do

  def setup
    if !defined?(@@adder_built)
      super
      @@adder_built = true 
      Extension.new "adder" do |e|
        e.sources full_dir("headers/Adder.h")
        e.namespace "classes"
      end

      require 'adder'
    end
  end

  specify "should make classes available as Ruby runtime constants" do
    assert defined?(Adder), "Adder isn't defined"
  end

  specify "should make wrapped classes constructable" do
    a = Adder.new
    a.should.not.be.nil
  end

  specify "should make functions of the class available" do
    # Wrapped method names default to underscore'd
    adder = Adder.new
    adder.add_integers(1,2).should == 3
    adder.add_floats(1.0, 2.0).should.be.close(3.0, 0.001)
    adder.add_strings("Hello", "World").should == "HelloWorld"
    adder.get_class_name.should == "Adder"
  end

  # Explicit self
  specify "should properly wrap static methods as class methods" do
    Adder.do_adding(1, 2, 3, 4, 5).should == 15
  end

end

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

