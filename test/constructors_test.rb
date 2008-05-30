require File.dirname(__FILE__) + '/test_helper'

context "Extension with constructors out the whazoo" do

  xspecify "should make constructors available" do
    Extension.new "constructors" do |e|
      e.sources full_dir("headers/constructors.h")
      node = e.namespace "constructors"
      e.writer_mode :single
    end

    require 'constructors'
    should.not.raise NameError do
#   Constructor overloading not yet supported
#     s = StringHolder.new
#     s.set_name "two"
#     s.get_name.should == "two"
 
      s2 = StringHolder.new "one"
      s2.get_name.should == "one"
    end

    should.not.raise NameError do
      # Test complex constructors
      d = DoubleStringHolder.new(StringHolder.new("one"), StringHolder.new("two"))
      d.get_one.get_name.should == "one"
      d.get_two.get_name.should == "two"
    end
    
    should.raise TypeError do
      PrivateConstructor.new
    end
  end

end
