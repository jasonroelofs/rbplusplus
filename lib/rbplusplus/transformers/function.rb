module RbGCCXML
  class Function < Node
    # Always true for functions, false for methods
    def static?
      !cache[:as_method]
    end
    
    # Sets this function to be an instance method.
    # Useful for custom function declaration.
    def as_instance_method
      cache[:as_method] = true
      self
    end

    # Are we wrapping this function as an instance method?
    def as_instance_method?
      !!cache[:as_method]
    end
    
    # Use this method to designate calling a different function
    # when the ruby method is requested
    #
    # TODO Is this really necessary?
    def calls(method_name) 
      cache[:special_qualified_name] = method_name
      self
    end

    def special_qualified_name
      cache[:special_qualified_name]
    end
    
    alias_method :method_qualified_name, :qualified_name
    def qualified_name #:nodoc:
      cache[:special_qualified_name] || method_qualified_name
    end
  end
end
