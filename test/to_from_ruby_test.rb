require File.dirname(__FILE__) + '/test_helper'

context "Properly build known required to_ruby and from_ruby methods" do

  specify "should build for const & types as needed" do
    Extension.new "to_from_ruby" do |e|
      e.sources full_dir("headers/to_from_ruby.h")
      e.namespace "to_from_ruby"
      e.writer_mode :single
    end

    require 'to_from_ruby'

    needs_to_ruby(4).value.should == 4
    some_other_method(7).value.should == 7

    c = WrappedClass.new
    c.get_my_type(17).value.should == 17
  end

end