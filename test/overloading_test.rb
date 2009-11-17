require 'test_helper'

context "Extension with overloaded methods" do

  specify "should have all functions available" do
    Extension.new "overload" do |e|
      e.sources full_dir("headers/overload.h")
      node = e.namespace "overload"
      mathy = node.classes("Mathy")
      mathy.methods("times")[0].wrap_as("times")

      mathy.use_constructor(
        mathy.constructors.find(:arguments => [:int])
      )
    end

    require 'overload'

    math = nil
    should.not.raise NameError do
      #Constructor overloading is broken in rice
      #math = Mathy.new 
      math = Mathy.new(1)
    end
    
    should.not.raise NameError do
      math.times.should.equal 1
      math.times_1(3).should.equal 3
      math.times_2(3,2).should.equal 6
      math.times_3(3,2,3).should.equal 18
    end
    
    should.not.raise NameError do
      math.nothing_0
      math.nothing_1(1)
    end

    # Should properly handle const overloads as well
    should.not.raise NameError do
      math.const_method_0(1).should.equal 1
      math.const_method_1(1).should.equal 2
      math.const_method_2("love").should.equal 4
    end

  end

end
