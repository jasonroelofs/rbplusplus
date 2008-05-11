module RbGCCXML
  class Constructor
    def public?
      return !(attributes["access"] == "private" || attributes["access"] == "protected")
    end
  end
end
