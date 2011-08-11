#ifndef __CUSTOM_TO_RUBY_H__
#define __CUSTOM_TO_RUBY_H__

#include <rice/Object.hpp>
#include <rice/to_from_ruby.hpp>

#include "my_type.hpp"

template<>
Rice::Object to_ruby<MyType>(MyType const & a);

template<>
MyType from_ruby<MyType>(Rice::Object x);

#endif
