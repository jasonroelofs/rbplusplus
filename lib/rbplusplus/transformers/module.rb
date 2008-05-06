module RbPlusPlus
  class RbModule
    def map(name,val)
      @functions ||= []
      @functions << FunctionReference.new(val, name)
      val.ignore
    end
    
    def functions
      functions = @functions || []
      functions << @node.functions if @node
      functions.flatten
    end
  end
end
