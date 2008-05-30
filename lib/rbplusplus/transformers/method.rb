module RbGCCXML
  class Method
    def calls(method_name) 
      @special_qualified_name = method_name
      self
    end
    
    alias_method :method_qualified_name, :qualified_name
    def qualified_name
      @special_qualified_name || method_qualified_name
    end
  end
end
