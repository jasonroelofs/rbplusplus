module RbGCCXML
  class Function < Node
    attr_reader :special_qualified_name
    
    # always true for functions, false for methods
    def static?
      !(@as_method || false)
    end
    
    # Sets this function to be an instance method.
    # Useful for custom function declaration.
    def as_instance_method
      @as_method = true
      return self
    end
    
    def calls(method_name) 
      @special_qualified_name = method_name
      self
    end
    
    alias_method :method_qualified_name, :qualified_name
    def qualified_name #:nodoc:
      @special_qualified_name || method_qualified_name
    end
  end
end
