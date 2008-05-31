require File.dirname(__FILE__) + '/test_helper'

context "Extension with overloaded methods" do

  specify "should have all functions available" do
    Extension.new "overload" do |e|
      e.sources full_dir("headers/overload.h")
      e.namespace "overload"
    end

    require 'overload'

    math = nil
    should.not.raise NameError do
      #math = Mathy.new
      math = Mathy.new(1)
    end
    
    should.not.raise NameError do
      math.times.should == 1
      math.times(3).should == 3
      math.times(3,2).should == 6
      math.times(3,2,3).should == 18
    end
    
    should.not.raise NameError do
      math.nothing
      math.nothing(1)
    end
 
    should.not.raise NameError do
      math.self.should == math
      math.self(math) == math
    end

  end

end
