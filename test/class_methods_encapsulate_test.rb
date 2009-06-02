require File.dirname(__FILE__) + '/test_helper'

context "Correct handling of encapsulated methods" do
  def setup
    if !defined?(@@encapsulated)
      super
      @@encapsulated = true 
      Extension.new "encapsulation" do |e|
        e.sources full_dir("headers/class_methods.h")
        node = e.namespace "encapsulation"
      end

      require 'encapsulation'
    end
  end

  specify "should handle private/protected/public" do
    ext = Extended.new
    ext.public_method.should == 1
    should.raise NoMethodError do
      ext.private_method
    end
    should.raise NoMethodError do
      ext.protected_method
    end
  end
  
  # The new director handling system breaks this test because Rice doesn't
  # know how to case a Base* to a BaseDirector* or even to an Extended*
  # Will work on figuring this out later
  xspecify "should handle virtual methods" do
    ext_factory = ExtendedFactory.new
    ext = ext_factory.new_instance
    ext.fundamental_type_virtual_method.should == 1
    ext.user_defined_type_virtual_method.class.should == Base
  end

  specify "don't wrap methods that use non-public types in their arguments" do
    arg = ArgumentAccess.new

    # Single argument methods
    should.raise NoMethodError do
      arg.wrap_me_private
    end
    should.raise NoMethodError do
      arg.wrap_me_protected
    end

    should.not.raise NoMethodError do
      arg.wrap_me_public ArgumentAccess::PublicStruct.new
    end
    
    # Multiple argument methods
    should.raise NoMethodError do
      arg.wrap_me_many_no
    end
    should.not.raise NoMethodError do
      arg.wrap_me_many_yes(1, 2.0, ArgumentAccess::PublicStruct.new)
    end
  end
end

