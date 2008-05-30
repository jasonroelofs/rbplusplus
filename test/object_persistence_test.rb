require File.dirname(__FILE__) + '/test_helper'

context "Object Persistence" do
  
  def validate(node)
    namespaces = node.namespaces
    
    node.namespaces.each_with_index do |n, i|
    
      #puts "#{node.name}::#{n.name}"
      namespaces[i].object_id.should == n.object_id
      
      classes = n.classes
      classes.each_with_index do |cls, j|
        namespaces[i].classes[j].object_id.should == cls.object_id
      
        methods = cls.methods
        methods.each_with_index do |m, k|
          #puts "#{n.name}::#{cls.name}::#{m.name}"
          namespaces[i].classes[j].methods[k].object_id.should == m.object_id
        end 
      end

      functions = n.functions  
      functions.each_with_index do |funct, j|
     #   puts "#{n.name}::#{funct.name}"
        namespaces[i].functions[j].object_id.should == funct.object_id
      end
      
      validate n
    end

  end

  specify "seperate query should lazy initialize objects" do
    Extension.new "ui" do |e|
      e.sources full_dir("headers/ugly_interface_ns.h")
      node = e.namespace("UI")
      validate(node)
    end
  end 
end
    

