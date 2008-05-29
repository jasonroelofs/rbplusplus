/**
 * This header file is for testing wrapping and using enumerations
 */

#ifndef __ENUMS__H__
#define __ENUMS__H__

#include <string>

namespace enums {
  enum TestEnum {
    VALUE1,
    VALUE2,
    VALUE3
  };

  namespace inner {
    enum InnerEnum {
      INNER_1,
      INNER_2
    };
  }

  std::string whatTestEnum(TestEnum e) {
    std::string ret = "We gots enum " + e;
    return ret;
  }

  class Tester {
    public:
      enum MyEnum {
        I_LIKE_MONEY = 3,
        YOU_LIKE_MONEY_TOO,
        I_LIKE_YOU = 7
      };

      std::string getEnumDescription(MyEnum e) {
        std::string ret;
        switch(e) {
          case I_LIKE_MONEY:
            ret = "I like money";
            break;
          case YOU_LIKE_MONEY_TOO:
            ret = "You like money!";
            break;
          case I_LIKE_YOU:
            ret = "I like you too";
            break;
          default:
            ret = "What you say?";
            break;
        }

        return ret;
      }
  };
}

#endif
