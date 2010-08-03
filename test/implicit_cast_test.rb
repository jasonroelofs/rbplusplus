require 'test_helper'

context "Specify types to allow implicit casting" do

  def setup
    if !defined?(@@implict_cast_built)
      super
      @@implict_cast_built = true 
      Extension.new "implicit_cast" do |e|
        e.sources full_dir("headers/implicit_cast.h")
        e.writer_mode :single
          
        node = e.namespace "implicit_cast"

        # Can flag individual constructors
        node.classes("Explicit").constructors.
          find(:arguments => ["const Radian&"]).implicit_casting(false)

        # Or flag the class as a whole
        node.classes("NotImplicit").implicit_casting(false)
      end

      require 'implicit_cast'
    end
  end

  specify "proper constructor is exposed" do
    Degree.new(14).value_degrees.should == 14
    Radian.new(1).value_radians.should == 1
  end

  specify "can use Degree in place of Radian" do
    assert !is_obtuse(Degree.new(75))
  end

  specify "can use Radian in place of Degree" do
    assert !is_acute(Radian.new(2.0))
  end

  specify "pointers also work fine" do
    assert is_right(Degree.new(90))
    assert !is_right(Radian.new(2.0))
  end

  specify "can turn off implicit cast wrapping for a given constructor" do

    should.raise do
      explicit_value(Radian.new(60.0))
    end

    should.not.raise do
      e = Explicit.new(14.0)
      explicit_value(e).should.be.close 14.0, 0.001
    end
  end

  specify "can turn off implicit casting for an entire class" do
    n = NotImplicit.new(10.0, 3)
    
    not_implicit_value(n).should.be.close 30.0, 0.001

    should.raise do
      not_implicit_value(Degree.new(15.0))
    end

    should.raise do
      not_implicit_value(Radian.new(1.0))
    end
  end

end

