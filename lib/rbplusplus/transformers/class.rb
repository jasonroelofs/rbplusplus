module RbGCCXML
  class Class
    # Class can map external methods/functions as class level methods
    def map(name, val)
      @methods ||= []
      @methods << NodeReference.new(val, name)
      val.ignore 
    end
    
    alias_method :rbgccxml_methods, :methods
    def methods(*args)
      return rbgccxml_methods(*args) + (@methods || [])
    end
  end
end

module RbGCCXML
  class Function
    # always true for functions
    def static?
      true
    end
  end
end
