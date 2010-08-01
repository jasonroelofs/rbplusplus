module RbGCCXML
  class Node

    # Specify to Rb++ that this node is not to be wrapped
    def ignore
      @ignored = true
    end

    # Un-ignore this node, useful if there's a glob ignore and the wrapper
    # just wants a few of the classes
    def unignore
      @ignored = false
    end

    # Has this node been previously declared to not be wrapped?
    def ignored?
      !!@ignored
    end

    # Specifies that this node has been included somewhere else
    def moved_to=(val)
      @moved_to = val
    end

    # Change what the name of this node will be when wrapped into Ruby
    def wrap_as(name)
      @wrap_as = name
      self
    end

    # Where has this node moved to?
    def moved_to
      @moved_to
    end

    # Has this node been renamed
    def renamed?
      !!@wrap_as
    end

    alias_method :rbgccxml_name, :name
    def name #:nodoc:
      @wrap_as || rbgccxml_name
    end

    def cpp_name
      rbgccxml_name
    end

    # In some cases, the automatic typedef lookup of rb++ can end up
    # doing the wrong thing (for example, it can take a normal class
    # and end up using the typedef for stl::container<>::value_type).
    # Flag a given class as ignoring this typedef lookup if this
    # situation happens.
    def disable_typedef_lookup
      @disable_typedef_lookup = true
    end

    def _disable_typedef_lookup? #:nodoc:
      !!@disable_typedef_lookup
    end

    # Is this node an incomplete node?
    # TODO Move to rbgccxml
    def incomplete?
      self["incomplete"] ? self["incomplete"] == "1" : false
    end
  end
end
