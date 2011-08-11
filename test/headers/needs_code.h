#ifndef __NEEDS_CODE_H__
#define __NEEDS_CODE_H__

#include "code/my_type.hpp"

namespace needs_code {

  const int getNumber(MyType in) {
    return in.value();
  }
}

#endif
