module RbPlusPlus
  class NodeCache
    include Singleton
    def get(node)
      @@nodes ||= {}
      if @@nodes[node.qualified_name].nil?
        @@nodes[node.qualified_name] = node
      end
      return @@nodes[node.qualified_name]
    end
    
    def clear
      @@nodes = {}
    end
  end
end
