require 'test_helper'

describe "Wrapping enumerations" do

  before(:all) do
    Extension.new "enums" do |e|
      e.sources full_dir("headers/enums.h")
      e.namespace "enums"
      e.writer_mode :single

      e.module "Mod" do |m|
        m.namespace "inner"
      end
    end

    require 'enums'
  end

  specify "should wrap up enums properly" do
    lambda { TestEnum }.should_not raise_error(NameError)

    TestEnum::VALUE1.to_i.should == 0
    TestEnum::VALUE2.to_i.should == 1
    TestEnum::VALUE3.to_i.should == 2
  end
  
  specify "should only wrap public enums" do
    lambda { Tester::NotWrapped }.should raise_error(NameError)
    lambda { Tester::AlsoNotWrapped }.should raise_error(NameError)
  end

  specify "should wrap up enumerations at proper nesting" do
    lambda { Tester::MyEnum }.should_not raise_error(NameError)

    Tester::MyEnum::I_LIKE_MONEY.to_i.should == 3
    Tester::MyEnum::YOU_LIKE_MONEY_TOO.to_i.should == 4
    Tester::MyEnum::I_LIKE_YOU.to_i.should == 7
  end

  specify "should work in user-defined modules" do
    lambda { Mod::InnerEnum }.should_not raise_error(NameError)

    Mod::InnerEnum::INNER_1.to_i.should == 0
    Mod::InnerEnum::INNER_2.to_i.should == 1
  end

  specify "should allow use of enumerations as types" do
    what_test_enum(TestEnum::VALUE1).should == "We gots enum 0";

    # Types should be adhered to
    lambda do
      what_test_enum(Mod::InnerEnum::INNER_1)
    end.should raise_error(RuntimeError)

    t = Tester.new
    t.get_enum_description(Tester::MyEnum::YOU_LIKE_MONEY_TOO).should == "You like money!"
  end

  specify "should properly build to_ruby converters for const enum return types" do
    t = Tester.new
    t.get_an_enum("I like money").should == Tester::MyEnum::I_LIKE_MONEY
    t.get_an_enum("You like money").should == Tester::MyEnum::YOU_LIKE_MONEY_TOO
  end

  specify "anonymous enumerations' values are added as constants to the parent class" do
    lambda { Tester::ANON_ENUM_VAL1 }.should_not raise_error(NameError)
    lambda { Tester::ANON_ENUM_VAL2 }.should_not raise_error(NameError)
    lambda { Tester::ANON_ENUM_VAL3 }.should_not raise_error(NameError)
    lambda { Tester::ANON_ENUM_VAL4 }.should_not raise_error(NameError)

    Tester::ANON_ENUM_VAL1.should == 1
    Tester::ANON_ENUM_VAL2.should == 2
    Tester::ANON_ENUM_VAL3.should == 5
    Tester::ANON_ENUM_VAL4.should == 3
  end

  specify "top-level anonymous enumerations' values are added to the global scope" do
    lambda { OUTER_ANON_1 }.should_not raise_error(NameError)
    lambda { OUTER_ANON_2 }.should_not raise_error(NameError)
    lambda { FOURTY_TWO }.should_not raise_error(NameError)
    lambda { SEPERATE_OUTER_VALUE }.should_not raise_error(NameError)

    OUTER_ANON_1.should == 0
    OUTER_ANON_2.should == 1
    FOURTY_TWO.should == 42
    SEPERATE_OUTER_VALUE.should == 14
  end

  specify "works with single element enumerations" do
    Tester::SINGLE_VALUE.to_i.should == 12
  end
end
