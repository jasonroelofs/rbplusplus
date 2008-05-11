module RbGCCXML
  class Method
    def public?
      return !(attributes["access"] == "private" || attributes["access"] == "protected")
   end
 end
end
