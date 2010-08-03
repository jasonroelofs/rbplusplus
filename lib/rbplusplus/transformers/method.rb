module RbGCCXML
  class Method < Function

    # Specifies a default return value for the
    # virtual method wrapper that rb++ will build
    # for this method.
    #
    # This will be needed in the situation where you
    # have a Ruby wrapped class where a C++ method calls
    # another method on the same object that's polymorphic.
    # Rice is unable to figure out the correct path to take,
    # and usually ends up trying to go back up the chain,
    # throwing the NotImplementedError.
    #
    # Specifying this option will turn the throw line into
    # a return line.
    #
    # See director_test's use of do_process_impl for an
    # example of this functionality.
    def default_return_value(value = nil)
      if value
        @default_return_value = value
      else
        @default_return_value
      end
    end
  end
end

