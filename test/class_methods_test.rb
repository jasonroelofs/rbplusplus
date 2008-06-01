require File.dirname(__FILE__) + '/test_helper'

context "Correct handling of static methods" do
  def setup
    if !defined?(@@complex_static)
      super
      @@complex_static = true 
      Extension.new "complex" do |e|
        e.sources full_dir("headers/complex_static_methods.h")
        node = e.namespace "complex"
      end

      require 'complex'
    end
  end

  specify "should handle complex static methods" do
    Multiply.multiply(SmallInteger.new(2),SmallInteger.new(2)).should == 4
  end
  
end

context "Correct handling of encapsulated methods" do
  def setup
    if !defined?(@@encapsulated)
      super
      @@encapsulated = true 
      Extension.new "encapsulation" do |e|
        e.sources full_dir("headers/class_methods.h")
        node = e.namespace "encapsulation"
      end

      require 'encapsulation'
    end
  end

  specify "should handle private/protected/public" do
    ext = Extended.new
    ext.public_method.should == 1
    should.raise NoMethodError do
      ext.private_method
    end
    should.raise NoMethodError do
      ext.protected_method
    end
  end
  
  specify "should handle virtual methods" do
    ext_factory = ExtendedFactory.new
    ext = ext_factory.new_instance
    ext.fundamental_type_virtual_method.should == 1
    ext.user_defined_type_virtual_method.class.should == Extended
  end
end

