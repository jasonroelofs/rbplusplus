module RbGCCXML
  class Function
    def ignore
      @ignored = true
    end
    
    def ignored?
      @ignored || false
    end
  end
end

module RbPlusPlus
  class FunctionReference
    attr_reader :name
    def initialize(from, name)
      @delegate = from
      @name = name
    end
    
    def method_missing(name, *args)
      @delegate.send name, *args
    end
    
    def ignored?
      false
    end
  end
end
