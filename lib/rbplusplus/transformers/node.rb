module RbGCCXML
  class Node    
    def ignore
      @ignored = true
    end
    
    def ignored?
      @ignored || false
    end

  end  
end

module RbPlusPlus
  class NodeReference
    attr_reader :name
    def initialize(from, name)
      @delegate = from
      @name = name
    end
    
    def method_missing(name, *args)
      @delegate.send name, *args
    end
    
    def ignored?
      false
    end
    
    def methods(*args)
      @delegate.methods *args
    end
    
    def references?(klass)
      return true if @delegate.is_a?(klass)
      return true if @delegate.is_a?(NodeReference) && @delegate.references?(klass)
      return false
    end 
  end
end
