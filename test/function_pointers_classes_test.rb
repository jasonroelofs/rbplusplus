require File.dirname(__FILE__) + '/test_helper'

context "Function pointers into class methods" do

  def setup
    if !defined?(@@function_pointers_class)
      super
      @@function_pointers_class = true 
      Extension.new "function_pointers_class" do |e|
        e.sources full_dir("headers/function_pointers_class.h")
        node = e.namespace "function_pointers_class"
      end

      require 'function_pointers_class'
    end
  end


  specify "works" do
    t = PointerTest.new
    t.set_callback do |i|
      42
    end

    t.call_callback(12).should == 42
  end
end
