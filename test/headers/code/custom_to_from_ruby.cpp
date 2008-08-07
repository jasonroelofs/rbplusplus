#include "custom_to_from_ruby.hpp"

template<>
Rice::Object to_ruby<short int>(short int const & a) {
  return INT2NUM(a);
}

template<>
short int from_ruby<short int>(Rice::Object x) {
  return FIX2INT(x.value());
}
