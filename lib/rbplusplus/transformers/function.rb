module RbGCCXML
  class Function
    attr_reader :special_qualified_name
    
    def ignored?
      return true if @ignored
      
      # ignore methods with void* in them, unless a special handler has been created.
      unless(@special_qualified_name)
        arguments.each do |argument|
          if argument.cpp_type.is_type?("void*") 
            puts "WARNING: ignoring '#{qualified_name}' due to an argument being 'void*'."
            puts "    USE: node.methods('#{to_s}').calls('myDefinedMethod') to create a custom method to handle this."
            return true            
          end
        end
        unless(self.is_a?(Constructor))
          if(return_type.is_a?(RbGCCXML::Type) && return_type.is_type?("void*"))
            puts "WARNING: ignoring '#{qualified_name}' due to the return type being 'void*'."
            puts "    USE: node.methods('#{to_s}').calls('myDefinedMethod') to create a custom method to handle this."
            return true
          end
        end
      end
      
      return false
    end
    
    # always true for functions, false for methods
    def static?
      !(@as_method || false)
    end
    
    # Sets this function to be an instance method.
    # Useful for custom function declaration.
    def as_instance_method
      @as_method = true
      return self
    end
    
    def calls(method_name) 
      @special_qualified_name = method_name
      self
    end
    
    alias_method :method_qualified_name, :qualified_name
    def qualified_name
      @special_qualified_name || method_qualified_name
    end
  end
end
