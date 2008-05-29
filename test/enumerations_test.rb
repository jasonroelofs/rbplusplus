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

  specify "should wrap up enumerations at proper nesting" do
    assert defined?(Tester::MyEnum)

    Tester::MyEnum::I_LIKE_MONEY.to_i.should == 3
    Tester::MyEnum::YOU_LIKE_MONEY_TOO.to_i.should == 4
    Tester::MyEnum::I_LIKE_YOU.to_i.should == 7
  end

  xspecify "should allow use of enumerations as types" do

  end

end
