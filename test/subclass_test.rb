require 'test_helper'

describe "Extension with class hierachies" do

  specify "should make super classes methods available" do
    Extension.new "subclass" do |e|
      e.sources full_dir("headers/subclass.h")

      node = e.namespace "subclass"
      node.classes("SuperSuper").ignore

      # Rice doesn't support multiple-inheritance (neither does Ruby), so for now
      # until we can fake it, force people to specify
      node.classes("Multiple").use_superclass( node.classes("Base2") )

      node.classes.implicit_casting(false)
    end

    require 'subclass'

    # Ignored superclasses should not cause problems with wrapped subclasses
    Base.new.one.should == Sub.new.one
    Base.new.zero.should == Sub.new.zero

    # Template superclasses shouldn't cause problems
    TemplateSub.new.zero.should == TemplateSub.new.custom

    # Shouldn't throw exceptions
    TemplatePtr.new.custom
    Multiple.new
    Multiple.superclass.should == Base2
  end

end
