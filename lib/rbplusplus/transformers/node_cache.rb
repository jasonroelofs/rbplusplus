module RbPlusPlus
  # This class controls node persistence.
  class NodeCache
    include Singleton
    # Retrieves a node from the cache based on the node's qualified name
    def get(node)
      demangled = node.attributes['demangled']
      @@nodes ||= {}
      if @@nodes[demangled].nil?
        @@nodes[demangled] = node
      end
      return @@nodes[demangled]
    end
    
    # Clears out the cache
    def clear
      @@nodes = {}
    end
  end
end
