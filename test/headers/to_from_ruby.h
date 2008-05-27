#ifndef __TO_FROM_RUBY_H__
#define __TO_FROM_RUBY_H__

namespace to_from_ruby {
  
  // Const methods that return references need an explicit to_ruby
  // definition for the given type
  class MyType {
    public:
    int myValue;

    MyType() { myValue = 0; }

    // Exposing attributes not implemented yet
    int value() { return myValue; }
  };

  const MyType& needsToRuby(int value) {
    MyType *type = new MyType();
    type->myValue = value;
    return *type;
  }

  // But rb++ should only make one to_ruby definition or the compiler
  // will poop
  const MyType& someOtherMethod(int value) {
    MyType *type = new MyType();
    type->myValue = value;
    return *type;
  };

  // Should also work with class methods
  class WrappedClass {
    public:
      WrappedClass() {}

      const MyType& getMyType(int value) {
        MyType *type = new MyType();
        type->myValue = value;
        return *type;
      }
  };
}

#endif 
