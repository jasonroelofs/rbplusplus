module RbPlusPlus
  class RbModule
    # Mapping is used to better fit ruby naming schemes, as well as to organize messy apis.
    #
    # Module is able to map the following:
    # Functions - the original function resolution will be implicitly ignored, and added as a module level method 
    #
    # ex. m.map "puts", node.functions("print")
    #
    # Classes - the class, and all methods under them, will referenced in this module.  The original class will be ignored
    #
    # ex. m.map "Vector3", node.classes("btVector3")
    #

    def map(name,val)
      if is_a?(val, RbGCCXML::Function)
        map_function(name,val)
      elsif is_a?(val, RbGCCXML::Class)
        map_class(name,val)
      else
        raise Exception.new("Unknown map for '#{val.class}'")
      end
    end
 
    # Other modules/namespaces can be included in this module.  The original module is ignored
    #
    # ex. m_math.map node.namespaces("MathExtraUtils")
    #   
    def include(m)
      if m.is_a?(Module) || m.is_a?(RbGCCXML::Namespace)
        map_module(m)      
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
    
    private
    def map_function(name, val)
      @functions ||= []
      @functions << NodeReference.new(val, name)
      val.ignore 
    end
    
    def map_class(name, val)
      @classes ||= []
      @classes << NodeReference.new(val,name)
      val.ignore
    end
    
    def map_module(m)
      m.functions.each do |f|
        map_function(f.name, f)
      end
      m.classes.each do |c|
        map_class(c.name, c)
      end
    end
    
    def is_a?(val, klass)
      return true if val.is_a?(klass)
      return true if val.is_a?(NodeReference) && val.references?(klass)
      return false
    end
  end
end
