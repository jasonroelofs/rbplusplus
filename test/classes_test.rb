require File.dirname(__FILE__) + '/test_helper'

context "Extension with wrapped classes" do

  def setup
    if !defined?(@@adder_built)
      super
      @@adder_built = true 
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

  specify "should use typedefs when findable" do
    assert defined?(IntAdder), "Did not use the typedef for TemplateAdder"
  end

  specify "finds and uses multi-nested typedefs" do
    assert defined?(ShouldFindMe), "Didn't find top level typedef for NestedTemplate"
  end

  specify "can turn off typedef lookup for certain classes" do
    assert !defined?(DontFindMeBro), "Found a typedef we shouldn't have"
  end

  specify "makes class constants available" do
    Adder::MY_VALUE.should == 10
  end

  specify "can ignore constants" do
    assert !defined?(Adder::HideMe), "Found HideMe when I shouldn't have"
  end

  specify "makes public instance variables accessible" do
    a = Adder.new
    a.value1 = 10
    a.value2 = 15.5
    a.value3 = "This is a value!"
    a.should_be_transformed = "TRANSFORM"

    a.value1.should.equal 10
    a.value2.should.be.close 15.5, 0.01
    a.value3.should.equal "This is a value!"

    a.should_be_transformed.should.equal "TRANSFORM"
  end

  specify "const variables are exported as read-only" do
    a = Adder.new

    should.raise NoMethodError do
      a.const_var = "This is a value!"
    end

    a.const_var.should.equal 14
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
    a.add_integers(3, 7).should.equal 21
    a.add_strings("piz", "owned").should.equal "pizownedwoot"
  end

  specify "should not wrap incomplete types" do
    assert !defined?(Forwarder)
  end
end

