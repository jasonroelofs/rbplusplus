#ifndef __CUSTOM_TO_RUBY_H__
#define __CUSTOM_TO_RUBY_H__

#include <rice/Object.hpp>
#include <rice/to_from_ruby.hpp>

template<>
Rice::Object to_ruby<short int>(short int const & a);

template<>
short int from_ruby<short int>(Rice::Object x);

#endif
