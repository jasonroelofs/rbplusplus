require File.dirname(__FILE__) + '/test_helper'

context "Extension with globally available functions" do

  specify "should make functions available" do
    Extension.new "functions" do |e|
      e.sources full_dir("headers/functions.h")
      e.namespace "functions"
    end

    require 'functions'

    should.not.raise NameError do
      test1
    end

    should.not.raise NameError do
      assert_in_delta 1.0, test2(2.0), 0.001
    end

    should.not.raise NameError do
      test3(2, 4.2).should == 2
    end
    
    should.raise NameError do
      void_star
    end
    
    should.raise NoMethodError do
      takes_void_star(nil)
    end
    
    should.raise NameError do
      typedefed_void_star
    end
  end

end
