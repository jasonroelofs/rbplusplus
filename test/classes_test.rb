require 'test_helper'

describe "Extension with wrapped classes" do

  before(:all) do
    Extension.new "adder" do |e|
      e.sources full_dir("headers/Adder.h"),
        :include_source_files => [
          full_dir("headers/Adder.h"),
          full_dir("headers/Adder.cpp")
        ]
      node = e.namespace "classes"
      adder = node.classes("Adder")
      adder.use_constructor(
        adder.constructors.find(:arguments => [])
      )

      adder.constants("HideMe").ignore
      adder.disable_typedef_lookup
    end

    require 'adder'
  end

  specify "should make classes available as Ruby runtime constants" do
    lambda { Adder }.should_not raise_error
  end

  specify "should make wrapped classes constructable" do
    a = Adder.new
    a.should_not be_nil
  end

  specify "should make functions of the class available" do
    # Wrapped method names default to underscore'd
    adder = Adder.new
    adder.add_integers(1,2).should == 3
    adder.add_floats(1.0, 2.0).should be_within(0.001).of(3.0)
    adder.add_strings("Hello", "World").should == "HelloWorld"
    adder.get_class_name.should == "Adder"
  end

  # Explicit self
  specify "should properly wrap static methods as class methods" do
    Adder.do_adding(1, 2, 3, 4, 5).should == 15
  end

  specify "should use typedefs when findable" do
    lambda { IntAdder }.should_not raise_error
  end

  specify "finds and uses multi-nested typedefs" do
    lambda { ShouldFindMe }.should_not raise_error
  end

  specify "can turn off typedef lookup for certain classes" do
    lambda { DontFindMeBro }.should raise_error
  end

  specify "makes class constants available" do
    Adder::MY_VALUE.should == 10
  end

  specify "can ignore constants" do
    lambda { Adder::HideMe }.should raise_error
  end

  specify "makes public instance variables accessible" do
    a = Adder.new
    a.value1 = 10
    a.value2 = 15.5
    a.value3 = "This is a value!"
    a.should_be_transformed = "TRANSFORM"

    a.value1.should == 10
    a.value2.should be_within(0.01).of(15.5)
    a.value3.should == "This is a value!"

    a.should_be_transformed.should == "TRANSFORM"
  end

  specify "const variables are exported as read-only" do
    a = Adder.new

    lambda do
      a.const_var = "This is a value!"
    end.should raise_error

    a.const_var.should == 14
  end

  specify "can subclass a wrapped class and go from there" do
    class MyAdder < Adder
      def add_integers(a, b)
        a * b
      end

      def add_strings(a, b)
        super(a, b) + "woot"
      end
    end

    a = MyAdder.new
    a.add_integers(3, 7).should == 21
    a.add_strings("piz", "owned").should == "pizownedwoot"
  end

  specify "should not wrap incomplete types" do
    lambda { Forwarder }.should raise_error
  end
end

