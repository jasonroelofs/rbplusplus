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
