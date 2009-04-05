module RbGCCXML
  class Node    

    # Specify to Rb++ that this node is not to be wrapped
    def ignore
      cache[:ignored] = true
    end
    
    # Has this node been previously declared to not be wrapped?
    def ignored?
      !!cache[:ignored]
    end

    # Specifies that this node has been included somewhere else
    def moved=(val)
      cache[:moved] = val
    end
    
    # Change what the name of this node will be when wrapped into Ruby
    def wrap_as(name)
      cache[:wrap_as] = name
      self
    end
    
    # Returns true if the node has been moved
    def moved?
      !!cache[:moved]
    end
    
    # Has this node been renamed
    def renamed?
      !!cache[:wrap_as]
    end

    alias_method :rbgccxml_name, :name	
    def name #:nodoc:
      cache[:wrap_as] || rbgccxml_name
    end

    def cpp_name
      rbgccxml_name
    end
    
    private

    # Get this node's settings cache
    def cache
      NodeCache.get(self)
    end
  end  
end
