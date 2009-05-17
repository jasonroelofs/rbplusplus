require File.dirname(__FILE__) + '/test_helper'

context "Extension with constructors out the whazoo" do

  specify "should make constructors available" do
    Extension.new "constructors" do |e|
      e.sources full_dir("headers/constructors.h")
      node = e.namespace "constructors"
      e.writer_mode :single


      node.classes("DoubleStringHolder").use_constructor(
        node.classes("DoubleStringHolder").constructors.find(:arguments => [nil, nil])
      )
    end

    require 'constructors'

    should.not.raise NameError do
      # Test complex constructors
      d = DoubleStringHolder.new("one", "two")
      one = d.get_one
      d.get_one.should == "one"
      d.get_two.should == "two"
    end
    
    should.raise TypeError do
      PrivateConstructor.new
    end
  end

end
