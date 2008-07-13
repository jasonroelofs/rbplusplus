module RbGCCXML
  class Node    
    # Specifies to not export this node
    def ignore
      @ignored = true
    end
    
    # Returns true if this node is ignored in exporting
    def ignored?
      @ignored || false
    end

    # Specifies that this node has been included somewhere else
    def moved=(val)
      @moved = val
    end
    
    # Change what the name of this node will be when wrapped into Ruby
    def wrap_as(name)
      @renamed = name
      self
    end
    
    # Returns true if the node has been moved
    def moved?
      @moved || false
    end
    
    # Has this node been renamed
    def renamed?
      (@renamed.nil? ? false : true)
    end

    alias_method :rbgccxml_namespaces, :namespaces
    def namespaces(*args) #:nodoc:
      nodes = rbgccxml_namespaces(*args)
      return cache(nodes)
    end
    
    alias_method :rbgccxml_classes, :classes
    def classes(*args) #:nodoc:
      nodes = rbgccxml_classes(*args)
      return cache(nodes)
    end
    
    alias_method :rbgccxml_functions, :functions
    def functions(*args) #:nodoc:
      nodes = rbgccxml_functions(*args)
      return cache(nodes)
    end
 
    alias_method :rbgccxml_methods, :functions
    def methods(*args) #:nodoc:
      nodes = rbgccxml_methods(*args)
      return cache(nodes)
    end   
 
    alias_method :rbgccxml_name, :name	
    def name #:nodoc:
      @renamed || rbgccxml_name
    end
    
    private
    # Looks up the objects in the node cache.
    def cache(nodes)
     if nodes.is_a?(QueryResult)
        retv = QueryResult.new 
        nodes.each do |node| 
          retv << RbPlusPlus::NodeCache.instance.get(node)
        end    
        return retv
      else
        return RbPlusPlus::NodeCache.instance.get(nodes)
      end    
    end
  end  
end
