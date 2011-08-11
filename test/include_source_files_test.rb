require 'test_helper'

describe "Using multiple include source files" do

  before(:each) do
    test_setup
  end

  specify "can specify individual files to be pulled into the compilation" do
    Extension.new "code_dir" do |e|
      e.sources full_dir("headers/needs_code.h"),
        :include_source_files => [
          full_dir("headers/code/my_type.hpp"),
          full_dir("headers/code/custom_to_from_ruby.hpp"),
          full_dir("headers/code/custom_to_from_ruby.cpp")
        ]

      e.namespace "needs_code"
    end

    require 'code_dir'

    NeedCode1.new.get_number(2).should == 2
    NeedCode2.new.get_number(2).should == 2
    NeedCode3.new.get_number(2).should == 2
  end

end
