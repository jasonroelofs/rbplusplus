#include "to_from_ruby.h"

namespace to_from_ruby {

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

  int usingConstString(const std::string& in) {
    return in.size();
  }
}
