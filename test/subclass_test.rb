require 'test_helper'

context "Extension with class hierachies" do

  specify "should make super classes methods available" do
    Extension.new "subclass" do |e|
      e.sources full_dir("headers/subclass.h")

      node = e.namespace "subclass"
      node.classes("SuperSuper").ignore

      # Rice doesn't support multiple-inheritance (neither does Ruby), so for now
      # until we can fake it, force people to specify
      node.classes("Multiple").use_superclass( node.classes("Base2") )
    end

    require 'subclass'

    # Ignored superclasses should not cause problems with wrapped subclasses
    should.not.raise NameError do
      Base.new.one.should == Sub.new.one
      Base.new.zero.should == Sub.new.zero
    end

    # Template superclasses shouldn't cause problems
    should.not.raise NameError do
      TemplateSub.new.zero.should == TemplateSub.new.custom
    end

    should.not.raise NameError do
      TemplatePtr.new.custom
    end

    should.not.raise NameError do
      Multiple.new
    end

    Multiple.superclass.should.equal Base2
  end

end
