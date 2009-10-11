module RbGCCXML
  class Namespace < Node

    # For easy compatibility between #methods
    # and #functions in the builder system
    def methods(*args) #:nodoc:
      self.functions(*args)
    end

  end
end
    
