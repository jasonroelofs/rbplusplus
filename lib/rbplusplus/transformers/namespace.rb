module RbGCCXML
  class Namespace < Node

    # TODO: Should this be put in rbgccxml?
    def methods(*args)
      self.functions(*args)
    end

  end
end
    
