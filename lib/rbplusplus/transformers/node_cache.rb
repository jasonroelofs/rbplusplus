module RbPlusPlus
  # This class controls node persistence.
  class NodeCache
    include Singleton
    # Retrieves a node from the cache based on the node's qualified name
    def get(node)
      @@nodes ||= {}
      if @@nodes[node.qualified_name].nil?
        @@nodes[node.qualified_name] = node
      end
      return @@nodes[node.qualified_name]
    end
    
    # Clears out the cache
    def clear
      @@nodes = {}
    end
  end
end
