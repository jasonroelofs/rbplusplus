#ifndef __NEEDS_CODE_H__
#define __NEEDS_CODE_H__

#include "code/my_type.hpp"

namespace needs_code {

  class NeedCode1 {
    public:
      const int getNumber(MyType in) {
        return in.value();
      }
  };

  class NeedCode2 {
    public:
      const int getNumber(MyType in) {
        return in.value();
      }
  };

  class NeedCode3 {
    public:
      const int getNumber(MyType in) {
        return in.value();
      }
  };
}

#endif
