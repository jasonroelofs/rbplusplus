module RbGCCXML
  class Class
    
    # Class can include external methods/functions as class level methods
    # also supports instance level methods
    #
    # ex. 
    #    math_class.includes node.namespaces("Math").functions("mod")
    # or for a instance method:
    #    math_class.includes node.namespaces("Math").functions("mod").as_method
    #
    def includes(val)
      @methods ||= []
      @methods << NodeReference.new(val)
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
    
    
    # returns a list of superclasses of this node, including the nodes class
    def super_classes
      retv = []
      retv << self
      unless node.attributes['bases'] == ""
        node.attributes['bases'].split.each do |cls_id|
          c = XMLParsing.find(:type => "Class", :id => cls_id)
          if c.nil?
            puts "#{self.qualified_name} has base ids #{node.attributes['bases']}, specifically #{cls_id} returning null "
            next
          end
          c = NodeCache.instance.get(c)
          retv << c unless c.ignored?
        end
      end
      
      return retv
    end
    
  end
end

