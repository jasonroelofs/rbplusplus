module RbGCCXML
  class Class
    # Class can include nested classes and nested structs.
    #
    # Class can also include external methods/functions as class level methods
    # also supports instance level methods
    #
    # ex. 
    #    math_class.includes node.namespaces("Math").functions("mod")
    # or for a instance method:
    #    math_class.includes node.namespaces("Math").functions("mod").as_method
    # or for nesting a class/struct:
    #    math_class.includes node.namespaces("Math").classes("Degree")
    #
    def includes(val)
      if (val.is_a?(RbGCCXML::Struct) || val.is_a?(RbGCCXML::Class))
        @classes ||= []
        @classes << RbPlusPlus::NodeReference.new(val)
      else
        @methods ||= []
        @methods << RbPlusPlus::NodeReference.new(val)
      end
      val.moved=true 
    end
    
    alias_method :rbgccxml_methods, :methods
    def methods(*args)
      nodes = rbgccxml_methods(*args)
      methods = @methods || QueryResult.new
      methods << cache(nodes)
      methods.flatten!
      return methods if args.empty?
      return (methods.size == 1 ? methods[0] : methods)
    end

    alias_method :node_classes, :classes
    def classes(*args)
      [@classes || [], node_classes].flatten
    end
      
    
    # returns a list of superclasses of this node, including the nodes class
    def super_classes
      retv = []
      unless node.attributes['bases'].nil? || node.attributes['bases'] == ""
        node.attributes['bases'].split.each do |cls_id|
          c = XMLParsing.find(:type => "Class", :id => cls_id)
          c = XMLParsing.find(:type => "Struct", :id => cls_id) if c.nil?
          if c.nil?
            puts "#{self.qualified_name} cannot find super class for id #{cls_id} "
            next
          end
          c = RbPlusPlus::NodeCache.instance.get(c)
          retv << c unless c.ignored?
        end
      end
      
      return retv
    end
    
  end
end

