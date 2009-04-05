require File.dirname(__FILE__) + '/test_helper'

context "Extension with class hierachies" do

  specify "should make super classes methods available" do
    Extension.new "subclass" do |e|
      e.sources full_dir("headers/subclass.h")
      node = e.namespace "subclass"
      
      node.classes("SuperSuper").ignore
      e.module("Sub") do |m|
        node.classes.each do |c|
          m.includes c
        end
      end
    end

    require 'subclass'

    # Ignored superclasses should not cause problems with wrapped subclasses
    should.not.raise NameError do
      Sub::Base.new.one.should == Sub::Sub.new.one
      Sub::Base.new.zero.should == Sub::Sub.new.zero
    end

    # Template superclasses shouldn't cause problems
    should.not.raise NameError do
      Sub::TemplateSub.new.zero.should == Sub::TemplateSub.new.custom
    end

    should.not.raise NameError do
      Sub::TemplatePtr.new.custom
    end
  end

end
