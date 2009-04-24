require File.dirname(__FILE__) + '/test_helper'

context "Correct handling of static methods" do
  def setup
    if !defined?(@@complex_static)
      super
      @@complex_static = true 
      Extension.new "complex_test" do |e|
        e.sources full_dir("headers/complex_static_methods.h")
        node = e.namespace "complex"
      end

      require 'complex_test'
    end
  end

  specify "should handle complex static methods" do
    Multiply.multiply(SmallInteger.new(2),SmallInteger.new(2)).should == 4
  end
  
end

