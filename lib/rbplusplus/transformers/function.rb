module RbGCCXML
  class Function < Node
    # Always true for functions, false for methods
    def static?
      !@as_method
    end

    # Sets this function to be an instance method.
    # Useful for custom function declaration.
    def as_instance_method
      @as_method = true
      self
    end

    # Are we wrapping this function as an instance method?
    def as_instance_method?
      !!@as_method
    end

    # For Class#needs_director?
    def purely_virtual?
      false
    end
  end
end
