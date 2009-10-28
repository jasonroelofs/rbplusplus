#ifndef __DEFAULT_ARGS_H__
#define __DEFAULT_ARGS_H__

#include <string>
#include <iostream>
using namespace std;

namespace default_args {

  // Global functions
  int global_do(int x, int y = 3, int z = 10) {
    return x * y * z;
  }

  // Module functions
  int module_do(int x, int y = 3, int z = 10) {
    return x + y + z;
  }

  class Tester {
    public:
      Tester() { }

      // Class methods
      std::string concat(std::string value1, std::string value2, const char* with = "-") {
        return value1 + std::string(with) + value2;
      }

      // Class static methods
      static std::string build(std::string base, int times = 3) {
        std::string out = "";
        for(int i = 0; i < times; i++) {
          out += base;
        }
        return out;
      }
  };

  class Directed {
    public:
      // Director methods
      virtual int virtualDo(int x, int y = 10) {
        return x * y;
      }
  };

  enum Ops {
    ADD,
    REMOVE
  };

  int modify(int value, Ops by = ADD) {
    switch(by) {
      case ADD:
        return value + 10;
        break;
      case REMOVE:
        return value - 10;
        break;
    }
    return value;
  }


}

#endif // __DEFAULT_ARGS_H__
