require File.dirname(__FILE__) + '/test_helper'

context "Ugly interfaces cleaner" do

  specify "should map functions detailed" do
    node = nil
    
    
    Extension.new "ui" do |e|
      e.sources full_dir("headers/ugly_interface_ns.h")
      node = e.namespace("UI")
    
      # test the no export option
      node.functions("uiIgnore").ignore
          
      e.module "UI" do |m|
        m.module "Math" do |m_math|
          #function wrapping
          m_math.includes node.functions("uiAdd").wrap_as("add")
          node.functions("uiAdd").ignored?.should == false
          node.functions("uiAdd").moved?.should == true
          
          m_math.includes node.functions("ui_Subtract").wrap_as("subtract")
          m_math.includes node.namespaces("DMath").functions("divide")
        end
        
        #class wrapping
        vector = node.classes("C_UIVector").wrap_as("Vector")
        vector.methods("x_").wrap_as("x")
        vector.methods("set_x").wrap_as("x=")
        
        # This is ignored because the C function Vector_y is not defined
        vector.methods("y_").calls("Vector_y").ignore
        vector.methods("y_").qualified_name.should == "Vector_y"
        
        m.includes vector
        
        #mapping stray functions to singleton methods
        modder = node.namespaces("I_LEARN_C").classes("Modder").wrap_as("Modulus")
        modder.includes node.namespaces("I_LEARN_C").functions("mod")
        modder.includes node.namespaces("I_LEARN_C").functions("mod2").wrap_as("method_mod").as_instance_method
        m.includes modder
        
        nc = node.classes("NoConstructor")
        nc.constructors.each { |c| c.ignore }
        m.includes nc 
        
        m.includes node.classes("Outside")
        node.classes("Outside").includes node.classes("Inside")
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
      v = UI::Vector.new
      v.x = 3
      v.x.should == 3
    end
    
    should.raise NameError do
      UI::DMath::divide(1.0,2.0)
    end
        
    should.not.raise NoMethodError do
      UI::Modulus.mod(3,2).should == 1
    end
    
    should.raise TypeError do
      UI::Modulus.new.method_mod(2)
    end
    
    should.not.raise NoMethodError do
      UI::Math::divide(2,1).should == 2
    end
    
    should.raise TypeError do
      UI::NoConstructor.new
    end
    
    should.not.raise NoMethodError do
      UI::Outside::Inside.new
    end
  end
end
