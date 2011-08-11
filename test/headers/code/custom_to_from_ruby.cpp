#include "custom_to_from_ruby.hpp"

template<>
Rice::Object to_ruby<MyType>(const MyType & a) {
  return INT2NUM(a.value());
}

template<>
MyType from_ruby<MyType>(Rice::Object x) {
  MyType my;
  my.setValue(FIX2INT(x.value()));
  return my;
}
