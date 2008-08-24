#ifndef UGLY_HELPER
#define UGLY_HELPER

#include "rice/Class.hpp"
#include "rice/Data_Type.hpp"
#include "rice/Constructor.hpp"
#include "rice/Enum.hpp"
#include "rice/to_from_ruby.hpp"
#include "rice/Address_Registration_Guard.hpp"

#include <ruby.h>
#include "ugly_interface_ns.h"

inline UI::C_UIVector *newInstanceButBetter(Rice::Object *self) {
  return new UI::C_UIVector();
}

#endif

