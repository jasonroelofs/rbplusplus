require File.dirname(__FILE__) + '/test_helper'

context "Wrapping enumerations" do

  def setup
    if !defined?(@@enums_built)
      super
      @@enums_built = true 
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
  end

  specify "should wrap up enums properly" do
    assert defined?(TestEnum)

    TestEnum::VALUE1.to_i.should == 0
    TestEnum::VALUE2.to_i.should == 1
    TestEnum::VALUE3.to_i.should == 2
  end
  
  specify "should only wrap public enums" do
    assert !defined?(Tester::NotWrapped)
    assert !defined?(Tester::AlsoNotWrapped)
  end

  specify "should wrap up enumerations at proper nesting" do
    assert defined?(Tester::MyEnum)

    Tester::MyEnum::I_LIKE_MONEY.to_i.should == 3
    Tester::MyEnum::YOU_LIKE_MONEY_TOO.to_i.should == 4
    Tester::MyEnum::I_LIKE_YOU.to_i.should == 7
  end

  specify "should work in user-defined modules" do
    assert defined?(Mod::InnerEnum)

    Mod::InnerEnum::INNER_1.to_i.should == 0
    Mod::InnerEnum::INNER_2.to_i.should == 1
  end

  specify "should allow use of enumerations as types" do
    what_test_enum(TestEnum::VALUE1).should == "We gots enum 0";

    # Types should be adhered to
    should.raise RuntimeError do
      what_test_enum(Mod::InnerEnum::INNER_1)
    end

    t = Tester.new
    t.get_enum_description(Tester::MyEnum::YOU_LIKE_MONEY_TOO).should == "You like money!"
  end

  specify "should properly build to_ruby converters for const enum return types" do
    t = Tester.new
    t.get_an_enum("I like money").should == Tester::MyEnum::I_LIKE_MONEY
    t.get_an_enum("You like money").should == Tester::MyEnum::YOU_LIKE_MONEY_TOO
  end

  specify "anonymous enumerations' values are added as constants to the parent class" do
    assert defined?(Tester::ANON_ENUM_VAL1)
    assert defined?(Tester::ANON_ENUM_VAL2)
    assert defined?(Tester::ANON_ENUM_VAL3)
    assert defined?(Tester::ANON_ENUM_VAL4)

    Tester::ANON_ENUM_VAL1.should.equal 1
    Tester::ANON_ENUM_VAL2.should.equal 2
    Tester::ANON_ENUM_VAL3.should.equal 5
    Tester::ANON_ENUM_VAL4.should.equal 3
  end

  specify "top-level anonymous enumerations' values are added to the global scope" do
    assert defined?(OUTER_ANON_1)
    assert defined?(OUTER_ANON_2)
    assert defined?(FOURTY_TWO)
    assert defined?(SEPERATE_OUTER_VALUE)

    OUTER_ANON_1.should.equal 0
    OUTER_ANON_2.should.equal 1
    FOURTY_TWO.should.equal 42
    SEPERATE_OUTER_VALUE.should.equal 14
  end
end
