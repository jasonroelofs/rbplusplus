require File.dirname(__FILE__) + '/test_helper'

context "Extension with globally available functions" do

  # Implicit self
  xspecify "should make functions available" do
    Extension.new "functions" do |e|
      e.sources full_dir("headers/functions.h")
      e.namespace "functions"
    end

    require 'functions'

    should.not.raise NameError do
      test1
    end

    should.not.raise NameError do
      test2.should.be.close 1.0 
    end

    should.not.raise NameError do
      test3(2, 4.2).should == 2
    end
  end

end
