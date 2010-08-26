require 'test_helper'

describe "Correct handling of encapsulated methods" do
  before(:all) do
    Extension.new "encapsulation" do |e|
      e.sources full_dir("headers/class_methods.h")
      node = e.namespace "encapsulation"
    end

    require 'encapsulation'
  end

  specify "should handle private/protected/public" do
    ext = Extended.new
    ext.public_method.should == 1

    lambda do
      ext.private_method
    end.should raise_error(NoMethodError)

    lambda do
      ext.protected_method
    end.should raise_error(NoMethodError)
  end
  
  specify "should handle virtual methods" do
    ext_factory = ExtendedFactory.new
    ext = ext_factory.new_instance
    ext.fundamental_type_virtual_method.should == 1
    ext.user_defined_type_virtual_method.class.should == Base
  end

  specify "don't wrap methods that use non-public types in their arguments" do
    arg = ArgumentAccess.new

    # Single argument methods
    lambda do
      arg.wrap_me_private
    end.should raise_error(NoMethodError)

    lambda do
      arg.wrap_me_protected
    end.should raise_error(NoMethodError)

    lambda do
      arg.wrap_me_public ArgumentAccess::PublicStruct.new
    end.should_not raise_error(NoMethodError)
    
    # Multiple argument methods
    lambda do
      arg.wrap_me_many_no
    end.should raise_error(NoMethodError)

    lambda do
      arg.wrap_me_many_yes(1, 2.0, ArgumentAccess::PublicStruct.new)
    end.should_not raise_error(NoMethodError)
  end
end

