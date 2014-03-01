require 'test_helper'

describe "Function pointers into class methods" do

  before(:all) do
    Extension.new "function_pointers_class" do |e|
      e.sources full_dir("headers/function_pointers_class.h")
      node = e.namespace "function_pointers_class"
    end

    require 'function_pointers_class'
  end


  specify "works" do
    t = PointerTest.new
    t.set_callback do |i|
      42
    end

    t.call_callback(12).should == 42
  end

  specify "keeps the block marked in the GC" do
    t = PointerTest.new
    t.set_callback do |i|
      14
    end

    t.call_callback(12)

    GC.start

    t.call_callback(12).should == 14
  end
end
