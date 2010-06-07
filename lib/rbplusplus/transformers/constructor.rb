module RbGCCXML
  class Constructor < Function

    # See:
    #   http://msdn.microsoft.com/en-us/library/h1y7x448.aspx
    #   http://msdn.microsoft.com/en-us/library/s2ff0fz8(VS.100).aspx
    #
    # Single argument constructors of a class are called Conversion constructors.
    # They manage the conversion of one type to another. Rice handles this functionality
    # through a special method, define_implicit_cast<From, To>(). 
    #
    # Rb++ attempts to find all classes and constructors that fit this pattern
    # and write out the casting declarations as needed. In the cases where this is
    # functionality not wanted, use this method to turn off this casting check.
    #
    # This method can be called per Constructor or per Class.
    def implicit_casting(state)
      cache[:implicit_casting] = state
    end

    def implicit_casting? #:nodoc:
      if cache[:implicit_casting].nil?
        cache[:implicit_casting] = true
      end

      cache[:implicit_casting]
    end

  end
end
