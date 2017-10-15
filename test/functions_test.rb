require 'test_helper'

describe "Extension with globally available functions" do

  specify "should make functions available" do
    Extension.new "functions" do |e|
      e.sources full_dir("headers/functions.h")
      e.namespace "functions"
    end

    require 'functions'

    test1

    test2(2.0).should be_within(0.001).of(1.0)

    test3(2, 4.2).should == 2
  end

end
