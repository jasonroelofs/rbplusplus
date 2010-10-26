require 'test_helper'

describe "Specify types to allow implicit casting" do

  before(:all) do
    Extension.new "implicit_cast" do |e|
      e.sources full_dir("headers/implicit_cast.h")
      e.writer_mode :single
        
      node = e.namespace "implicit_cast"

      # Can flag individual constructors
      node.classes("Degree").constructors.find(:arguments => ["const Radian&"]).implicit_casting(true)

      # Or flag the class as a whole
      node.classes("Radian").implicit_casting(true)
    end

    require 'implicit_cast'
  end

  specify "proper constructor is exposed" do
    Degree.new(14).value_degrees.should == 14
    Radian.new(1).value_radians.should == 1
  end

  specify "can use Degree in place of Radian" do
    is_obtuse(Degree.new(75)).should be_false
  end

  specify "can use Radian in place of Degree" do
    is_acute(Radian.new(2.0)).should be_false
  end

  specify "pointers also work fine" do
    is_right(Degree.new(90)).should be_true
    is_right(Radian.new(2.0)).should be_false
  end
end

