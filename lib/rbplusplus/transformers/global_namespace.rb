module RbPlusPlus
 class GlobalNamespace < RbGCCXML::Namespace
    #accepts the gccxml parser
    def initialize(parser)
      @functions = parser.functions
      @functions = RbGCCXML::QueryResult.new @functions.select { |fun| !(/^__built/ === fun.name) } # filter out builtin functions
      @classes = parser.classes
      @namespaces = parser.namespaces
      @structs = parser.structs
    end
    
    # parent always returns the GlobalNamespace
    def parent
      self
    end
    
    # not used
    def name
      "GlobalNamespace"
    end
    
    # GlobalNamespace has no qualified name
    def qualified_name
      ""
    end
    
    # Find all namespaces. There are two ways of calling this method:
    #   #namespaces  => Get all namespaces in this scope
    #   #namespaces(name) => Shortcut for namespaces.find(:name => name)
    def namespaces(name = nil)
      if name
        namespaces.find(:name => name)
      else
        @namespaces
      end
    end

    # Find all classes in this scope. Like #namespaces, there are
    # two ways of calling this method.
    def classes(name = nil)
      if name
        classes.find(:name => name)
      else
        @classes
      end
    end

    # Find all structs in this scope. Like #namespaces, there are
    # two ways of calling this method.
    def structs(name = nil)
      if name
        structs.find(:name => name)
      else
        @structs
      end
    end

    # Find all functions in this scope. Functions are free non-class
    # functions. To search for class methods, use #methods.
    # 
    # Like #namespaces, there are two ways of calling this method.
    def functions(name = nil)
      if name
        functions.find(:name => name)
      else
        @functions
      end
    end  
  end
end
