require File.dirname(__FILE__) + '/test_helper'

context "properly handles and wraps function pointer arguments" do

  def setup
    if !defined?(@@function_pointers)
      super
      @@function_pointers = true 
      Extension.new "function_pointers" do |e|
        e.sources full_dir("headers/function_pointers.h")
        node = e.namespace "function_pointers"
      end

      require 'function_pointers'
    end
  end

  specify "no arguments, no return" do
    proc_called = false

    set_callback do
      proc_called = true
    end

    call_callback

    assert proc_called
  end

  specify "arguments, no return" do
    proc_arg = nil

    set_callback_with_args do |i|
      proc_arg = i
    end

    call_callback_with_args(10)

    proc_arg.should == 10
  end

  specify "arguments and return" do
    proc_arg = nil
    set_callback_returns do |i|
      proc_arg = i
      i * 10
    end

    ret = call_callback_returns(8)

    proc_arg.should == 8
    ret.should == 80
  end

end

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
