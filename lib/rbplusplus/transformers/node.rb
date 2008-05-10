module RbGCCXML
  class Node    
    def ignore
      @ignored = true
    end
    
    def ignored?
      @ignored || false
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
    
    alias_method :rbgccxml_name, :name	
    def name
      @renamed || rbgccxml_name
    end
    
    def wrap_as(name)
      @renamed = name
      self
    end
    
    private
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
