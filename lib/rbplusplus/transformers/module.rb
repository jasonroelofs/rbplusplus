module RbPlusPlus
  class RbModule
    # Helper function for moving pieces of an API into other Ruby locations, eg from a Class to a Module, 
    # from global functions to a Class, or from Module to Module.
    #
    # Module may include Functions
    #   e.module "System" do |m|
    #     m.includes node.functions("print").wrap_as("puts") # Moves the ::print function into the System module
    #
    #     m.include node.classes("Vector3") # Explicitly put Vector3 class in the System module
    #   end
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
    
    def functions #:nodoc:
      functions = @functions || []
      functions << @node.functions if @node
      functions.flatten
    end
    
    def classes #:nodoc:
      classes = @classes || []
      classes << @node.classes if @node
      classes.flatten
    end
  
    def structs #:nodoc:
      structs = @structs || []
      structs << @node.structs if @node
      structs.flatten
    end
    
    private

    # Map a function from a different namespace
    def reference_function(val) #:nodoc:
      @functions ||= []
      @functions << NodeReference.new(val)
      val.moved=true 
    end
    
    # Map a class from a different namespace
    def reference_class(val) #:nodoc:
      @classes ||= []
      @classes << NodeReference.new(val)
      val.moved=true
    end
    
    def reference_struct(val) #:nodoc:
      @structs ||= []
      @structs << NodeReference.new(val)
      val.moved=true   
    end
        
    def is_a?(val, klass) #:nodoc:
      return true if val.is_a?(klass)
      return true if val.is_a?(NodeReference) && val.references?(klass)
      return false
    end
  end
end
