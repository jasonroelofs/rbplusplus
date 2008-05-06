module RbGCCXML
  class Class
    # Class can map external methods/functions as class level methods
    # also supports instance level methods
    #
    # ex. 
    #    math_class.map "mod", node.namespaces("Math").functions("mod")
    # or for a instance method:
    #    math_class.map "mod", node.namespaces("Math").functions("mod").as_method
    #
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
    # always true for functions, false for methods
    def static?
      !(@as_method || false)
    end
    
    def as_method
      @as_method = true
      return self
    end
  end
end
