require 'test_helper'

describe "Extension with overloaded methods" do

  specify "should have all functions available" do
    Extension.new "overload" do |e|
      e.sources full_dir("headers/overload.h")
      node = e.namespace "overload"
      mathy = node.classes("Mathy")
      mathy.methods("times")[0].wrap_as("times")

      mathy.use_constructor(
        mathy.constructors.find(:arguments => [:int])
      )

      mathy.methods("constMethod").find(:arguments => ["std::string"]).wrap_as("const_method_string")
    end

    require 'overload'

    #Constructor overloading is broken in rice
    #math = Mathy.new 
    math = Mathy.new(1)
    
    math.times.should == 1
    math.times_1(3).should == 3
    math.times_2(3,2).should == 6
    math.times_3(3,2,3).should == 18
    
    lambda do
      math.nothing_0
      math.nothing_1(1)
    end.should_not raise_error(NameError)

    # Should properly handle const overloads as well
    lambda do
      math.const_method_0(1)
      math.const_method_1(1)
      math.const_method_string("love")
    end.should_not raise_error(NameError)

  end

end
