module RbPlusPlus
  class NodeCache #:nodoc:
    # Retrieves or initializes a node's information cache
    def self.get(node)
      demangled = node.attributes['id']
      @@nodes ||= {}
      @@nodes[demangled] ||= {}
    end
    
    # Clears out the cache
    def self.clear
      @@nodes = {}
    end
  end
end
