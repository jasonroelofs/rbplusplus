module RbGCCXML
  class Function
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
    
    def public?
      true
    end
  end
end
