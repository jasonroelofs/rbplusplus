module RbGCCXML
  class Node    
    # Returns true if this node is a public node
    def public?
      return !(attributes["access"] == "private" || attributes["access"] == "protected")
    end

    # Specifies to not export this function
    def ignore
      @ignored = true
    end
    
    # Returns true if this object is ignored in exporting
    def ignored?
      @ignored || false
    end

    # Specifies that this function has been included somewhere else
    def moved=(val)
      @moved = val
    end
    
    # Returns true if the object has been moved
    def moved?
      @moved || false
    end
    
    def renamed?
      (@renamed.nil? ? false : true)
    end


    alias_method :rbgccxml_namespaces, :namespaces
    def namespaces(*args)
      nodes = rbgccxml_namespaces(*args)
      return cache(nodes)
    end
    
    
    alias_method :rbgccxml_classes, :classes
    def classes(*args)
      nodes = rbgccxml_classes(*args)
      return cache(nodes)
    end
    
    
    alias_method :rbgccxml_functions, :functions
    def functions(*args)
      nodes = rbgccxml_functions(*args)
      return cache(nodes)
    end
 
    alias_method :rbgccxml_methods, :functions
    def methods(*args)
      nodes = rbgccxml_methods(*args)
      return cache(nodes)
    end   
 
    alias_method :rbgccxml_name, :name	
    def name
      @renamed || rbgccxml_name
    end
    
    # Renames the ruby name of this node
    def wrap_as(name)
      @renamed = name
      self
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
