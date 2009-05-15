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
      find_with_cache(:classes, node_classes(*args))
    end

    alias_method :node_methods, :methods
    def methods(*args) #:nodoc:
      find_with_cache(:methods, node_methods(*args))
    end

    # Specify which superclass to use.
    # Because Rice doesn't support multiple inheritance right now,
    # we need to know which superclass Rice should use for this class.
    # An error message will show on classes with mutiple superclasses
    # where this method hasn't been used yet.
    #
    # klass should be the node for the class you want to wrap
    def use_superclass(klass)
      cache[:use_superclass] = klass
    end

    def get_superclass
      cache[:use_superclass]
    end

    private

    # Take the cache key, and the normal results, adds to the results
    # those that are in the cache and returns them properly.
    def find_with_cache(type, results)
      in_cache = cache[type]

      ret = QueryResult.new
      ret << results if results
      ret << in_cache if in_cache
      ret.flatten!

      ret.size == 1 ? ret[0] : ret
    end
  end
end

