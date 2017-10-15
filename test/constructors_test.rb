require 'test_helper'

describe "Extension with constructors out the whazoo" do

  specify "should make constructors available" do
    Extension.new "constructors" do |e|
      e.sources full_dir("headers/constructors.h")
      node = e.namespace "constructors"


      node.classes("DoubleStringHolder").use_constructor(
        node.classes("DoubleStringHolder").constructors.find(:arguments => [nil, nil])
      )
    end

    require 'constructors'

    # Test complex constructors
    d = DoubleStringHolder.new("one", "two")
    one = d.get_one
    d.get_one.should == "one"
    d.get_two.should == "two"

    lambda do
      PrivateConstructor.new
    end.should raise_error(TypeError)
  end

end
