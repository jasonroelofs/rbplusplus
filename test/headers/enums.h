/**
 * This header file is for testing wrapping and using enumerations
 */

#ifndef __ENUMS__H__
#define __ENUMS__H__

#include <iostream>
#include <sstream>

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
    std::stringstream stream;
    stream << "We gots enum " << e;
    return stream.str();
  }

  class Tester {
    public:
      Tester() {}

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

      MyEnum getAnEnum(std::string message) const {
        MyEnum e;

        if (message == "I like money") {
          e = I_LIKE_MONEY;
        } else if (message == "You like money") {
          e = YOU_LIKE_MONEY_TOO;
        } else if (message == "I like you") {
          e = I_LIKE_YOU;
        }
        
        return e;
      }
  };
}

#endif
