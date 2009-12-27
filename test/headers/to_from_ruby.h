#ifndef __TO_FROM_RUBY_H__
#define __TO_FROM_RUBY_H__

#include <string>

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

  const MyType& needsToRuby(int value);

  // But rb++ should only make one to_ruby definition or the compiler
  // will poop
  const MyType& someOtherMethod(int value);

  // Should also work with class methods
  class WrappedClass {
    public:
      WrappedClass() { myType = new MyType(); }

      ~WrappedClass() {
        if(myType) { delete myType; }
      }

      const MyType& getMyType(int value) {
        MyType *type = new MyType();
        type->myValue = value;
        return *type;
      }
      
      const MyType &overload() {
        return *myType;
      }
    
      const MyType &overload(int arg) {
        return *myType;
      }

    private:
      const MyType* myType;
  };

  /**
   * Some types, Rice already wraps for us. Make sure this doesn't cause
   * a compiler error
   */
  int usingConstString(const std::string& in);
  
  /* template tests */
  
  /*
  template<class T>
  class TemplateClass {
    T val;
    public:
      TemplateClass(T val) {
        this->val = val;
      }
      const T &overload() {
        return this->val;
      }
      const T &overload(int arg) {
        return this->val;
      }
  };
  
  inline const TemplateClass<int>* getTemplate() {
    return new TemplateClass<int>(1);
  }
  
  inline const TemplateClass<int>* getTemplate(int overload) {
    return new TemplateClass<int>(overload);
  }
  */
}

#endif 
