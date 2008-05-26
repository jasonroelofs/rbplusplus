module RbPlusPlus
  # A delegate to the Node.  Used in including nodes in modules and classes
  class NodeReference
    # Takes the delegate object as input
    def initialize(from)
      @delegate = from
    end
    
    # Delegate
    def method_missing(name, *args)
      @delegate.send name, *args
    end
    
    # Always false
    def moved?
      false
    end
    
    # Delegate
    def methods(*args)
      @delegate.methods *args
    end
    
    # Returns true if the class references the specified class
    def references?(klass)
      return true if @delegate.is_a?(klass)
      return true if @delegate.is_a?(NodeReference) && @delegate.references?(klass)
      return false
    end 
  end
end
