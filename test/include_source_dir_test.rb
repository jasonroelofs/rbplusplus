require 'test_helper'

describe "Using include_source_dir" do

  specify "can specify a directory containing code to be included into compilation process" do
    Extension.new "code_dir" do |e|
      e.sources full_dir("headers/needs_code.h"),
        :include_source_dir => full_dir("headers/code")

      e.namespace "needs_code"
    end

    require 'code_dir'

    NeedCode1.new.get_number(2).should == 2
  end

end
