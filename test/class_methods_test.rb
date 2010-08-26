require 'test_helper'

describe "Correct handling of static methods" do

  specify "should handle complex static methods" do
    Extension.new "complex_test" do |e|
      e.sources full_dir("headers/complex_static_methods.h")
      node = e.namespace "complex"
    end

    require 'complex_test'

    Multiply.multiply(SmallInteger.new(2),SmallInteger.new(2)).should == 4
  end
  
end

