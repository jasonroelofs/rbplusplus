require File.dirname(__FILE__) + '/test_helper'

context "Extension with constructors out the whazoo" do

  specify "should make constructors available" do
    Extension.new "constructors" do |e|
      e.sources full_dir("headers/constructors.h")
      e.namespace "constructors"
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

  end

end
