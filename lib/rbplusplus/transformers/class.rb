module RbGCCXML
  class Class < Node
    # Class can include nested classes and nested structs.
    #
    # Class can also include external methods/functions as class level methods
    # also supports instance level methods
    #
    # ex. 
    #
    #   math_class.includes node.namespaces("Math").functions("mod")
    #
    # or for a instance method:
    #
    #   math_class.includes node.namespaces("Math").functions("mod").as_instance_method
    #
    # or for nesting a class/struct:
    #
    #   math_class.includes node.namespaces("Math").classes("Degree")
    #
    def includes(val)
      if (val.is_a?(RbGCCXML::Struct) || val.is_a?(RbGCCXML::Class))
        cache[:classes] ||= []
        cache[:classes] << RbPlusPlus::NodeReference.new(val)
      else
        cache[:methods] ||= []
        cache[:methods] << RbPlusPlus::NodeReference.new(val)
      end
      val.moved = true 
    end
    
    alias_method :node_classes, :classes
    def classes(*args) #:nodoc:
      results = QueryResult.new
      results << (cache[:classes] || [])
      results << node_classes(*args)
      results.flatten!

      results.length == 1 ? results[0] : results
    end

    alias_method :node_methods, :methods
    def methods(*args) #:nodoc:
      results = QueryResult.new
      results << (cache[:methods] || [])
      results << node_methods(*args)
      results.flatten!

      results.length == 1 ? results[0] : results
    end
  end
end

