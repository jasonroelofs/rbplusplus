module RbPlusPlus
  class RbModule
    # includes is used to add elements from other namespaces, as well as to organize messy apis.
    #
    # Module is able to include the following types:
    # Functions - the original function resolution will be implicitly ignored, and added as a module level method 
    #
    # ex. m.include node.functions("print").wrap_as("puts")
    #
    # Classes - the class, and all methods under them, will referenced in this module.  The original class will be ignored
    #
    # ex. m.include node.classes("Vector3")
    #
    def includes(val)
      if is_a?(val, RbGCCXML::Function)
        reference_function(val)
      elsif is_a?(val, RbGCCXML::Class)
        reference_class(val)
      elsif is_a?(val, RbGCCXML::Struct)
        reference_struct(val)
      else
        raise "Cannot use #{self.class}#includes for type '#{val.class}'"
      end
    end
    
    def functions
      functions = @functions || []
      functions << @node.functions if @node
      functions.flatten
    end
    
    def classes
      classes = @classes || []
      classes << @node.classes if @node
      classes.flatten
    end
  
    def structs
      structs = @structs || []
      structs << @node.structs if @node
      structs.flatten
    end
    
    private
    # Map a function from a different namespace
    def reference_function(val)
      @functions ||= []
      @functions << NodeReference.new(val)
      val.moved=true 
    end
    
    # Map a class from a different namespace
    def reference_class(val)
      @classes ||= []
      @classes << NodeReference.new(val)
      val.moved=true
    end
    
    def reference_struct(val)
      @structs ||= []
      @structs << NodeReference.new(val)
      val.moved=true   
    end
        
    def is_a?(val, klass)
      return true if val.is_a?(klass)
      return true if val.is_a?(NodeReference) && val.references?(klass)
      return false
    end
  end
end
