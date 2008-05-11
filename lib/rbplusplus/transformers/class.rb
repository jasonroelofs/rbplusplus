module RbGCCXML
  class Class
    
    # Class can include external methods/functions as class level methods
    # also supports instance level methods
    #
    # ex. 
    #    math_class.includes node.namespaces("Math").functions("mod")
    # or for a instance method:
    #    math_class.includes node.namespaces("Math").functions("mod").as_method
    #
    def includes(val)
      @methods ||= []
      @methods << NodeReference.new(val)
      val.ignore 
    end
    
    alias_method :rbgccxml_methods, :methods
    def methods(*args)
      nodes = rbgccxml_methods(*args)
      methods = @methods || QueryResult.new
      methods << cache(nodes)
      methods.flatten!
      return methods if args.empty?
      return (methods.size == 1 ? methods[0] : methods)
    end
    
  end
end

