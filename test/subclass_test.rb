require File.dirname(__FILE__) + '/test_helper'

context "Extension with class hierachies" do

  specify "should make super classes methods available" do
    Extension.new "subclass" do |e|
      e.sources full_dir("headers/subclass.h")
      node = e.namespace "subclass"
    end

    require 'subclass'
    should.not.raise NameError do
      Base.new.one.should == Sub.new.one
    end
  end

end
