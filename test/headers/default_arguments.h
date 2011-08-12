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

      static std::string DEFAULT_WITH;

      // Class methods
      std::string concat(std::string value1, std::string value2, std::string with = default_args::Tester::DEFAULT_WITH) {
        return value1 + with + value2;
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

  std::string Tester::DEFAULT_WITH = std::string("-");
  static std::string KICK_IT = std::string("kick-it");

  // Make sure const and reference types are taken care of properly
  //std::string build_strings(std::string value1, const std::string& with = default_args::KICK_IT) {
    //return value1 + with;
  //}

  class Directed {
    public:
      // Director methods
      virtual int virtualDo(int x, int y = 10) {
        return x * y;
      }
  };

  enum Ops {
    ADD    = 0,
    REMOVE = 1
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

  // Seen in Ogre3D
  int modify2(int value, Ops* by = 0) {
    return value;
  }

  class CustomType {
    public:
      CustomType(int value) { theValue = value; };
      int theValue;

      // Function calls
      static CustomType someValue() { return CustomType(3); }
  };

  int defaultWithFunction(CustomType x = CustomType::someValue()) {
    return x.theValue;
  }

}

#endif // __DEFAULT_ARGS_H__
