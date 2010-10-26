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
    # Use this method to specify which constructors are meant to be used in implicit casting.
    # This will mark the constructor as such and won't wrap it directly, but will build an
    # appropriate define_implicit_cast<> call for the two types (class and argument)
    #
    # This method can be called per Constructor or per Class.
    def implicit_casting(state)
      @implicit_casting = state
    end

    def implicit_casting? #:nodoc:
      if @implicit_casting.nil?
        @implicit_casting = false
      end

      @implicit_casting
    end

  end
end
