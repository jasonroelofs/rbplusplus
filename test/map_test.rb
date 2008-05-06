require File.dirname(__FILE__) + '/test_helper'

context "Ugly interfaces cleaner" do

  specify "should map functions detailed" do
    node = nil
    
    def validate(node)
      node.parent.should == node
      node.class.should == GlobalNamespace
      node.functions.size.should > 0
      node.functions.each do |fun| 
        assert(!(/^__built/ === fun.name), "function #{fun.name} should not be exported")
      end
      node.classes.size.should > 0
      node.structs.size.should > 0
      node.namespaces.size.should > 0  
    end
    
    Extension.new "ui" do |e|
      e.sources full_dir("headers/ugly_interface.h")
      node = e.global_namespace
      validate node
      
      bad_ui = node.namespaces("__UI").namespaces("BAD_UI")
      node.functions("uiIgnore").ignore
          
      e.module "UI" do |m|
        m.module "Math" do |m_math|
          m_math.map "add", node.functions("uiAdd")
          m_math.map "subtract", node.functions("ui_Subtract")
          m_math.include node.namespaces("DMath")
        end
        
    #    m.map "math_add", node.functions("uiAdd") -- doesn't work due to duplicate wrap_ name generation
        m.map "Vector", node.classes("C_UIVector")
        
      end
    end
    
    require 'ui'
    
    should.raise NoMethodError do
      ui_ignore()
    end

    should.raise NoMethodError do
      ui_add(1,2)
    end

    should.not.raise NoMethodError do
      UI::Math::add(1,2).should == 3
    end

    should.raise NoMethodError do
      ui_subtract(2,1)
    end
    
    should.not.raise NoMethodError do
      UI::Math::subtract(2,1).should == 1
    end
    
    should.raise NameError do
      C_UIVector.new
    end
    
    should.not.raise NameError do
      UI::Vector.new
    end
    
    should.raise NameError do
      UI::DMath::divide(1.0,2.0)
    end
    
    should.not.raise NoMethodError do
      UI::Math::divide(2,1).should == 2
    end
  end
end
