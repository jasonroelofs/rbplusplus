require 'test_helper'

describe "Default arguments properly exposed" do

  before(:all) do
    Extension.new "defargs" do |e|
      e.sources full_dir("headers/default_arguments.h")
      e.writer_mode :single
      node = e.namespace "default_args"

      e.module "Inner" do |m|
        m.includes node.functions("module_do")
      end

      node.classes("Directed").director
    end

    require 'defargs'
  end

  specify "global functions" do
    global_do(1, 4, 5).should == 20
    global_do(1, 4).should == 40
    global_do(1).should == 30
  end

  specify "module functions" do
    Inner.module_do(5).should == 18
    Inner.module_do(5, 5).should == 20
    Inner.module_do(5, 5, 5).should == 15
  end

  specify "class instance methods" do
    tester = Tester.new
    tester.concat("this", "that").should == "this-that"
    tester.concat("this", "that", ";").should == "this;that"
  end

  specify "class static methods" do
    Tester.build("base").should == "basebasebase"
    Tester.build("woot", 5).should == "wootwootwootwootwoot"
  end

  specify "director methods" do
    d = Directed.new
    d.virtual_do(3).should == 30
    d.virtual_do(3, 9).should == 27

    class MyD < Directed
      def virtual_do(x, y = 10)
        super(x * 3, y)
      end
    end

    myd = MyD.new
    myd.virtual_do(10).should == 300
  end

  specify "throw argument error on bad types" do
    lambda do
      global_do(1, "three")
    end.should raise_error(TypeError)
  end

  # See MethodBase#fix_enumeration_value
  specify "properly handle incomplete enums in default values" do
    modify(1).should == 11
    modify(1, Ops::ADD).should == 11
    modify(1, Ops::REMOVE).should == -9
  end

  # Ogre does this to handle some weird pass-back-enum-that-signals-error (Ogre::Frustum::isVisible)
  specify "properly handle incomplete enums arguments with straight integer default values" do
    modify2(1).should == 1
    modify2(1, Ops::ADD).should == 1
    modify2(1, Ops::REMOVE).should == 1
  end

  specify "function calls" do
    default_with_function.should == 3
    default_with_function(CustomType.new(5)).should == 5
  end

  specify "should properly handle argument type qualifiers like refs and consts" # do
#    build_strings("I'd ").should == "I'd kick-it"
#    build_strings("You won't", " do it").should == "You won't do it"
#  end
end
