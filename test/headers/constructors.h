#ifndef __CONSTRUCTORS_H__
#define __CONSTRUCTORS_H__

#include <string>

using namespace std;

namespace constructors {
  class DoubleStringHolder {
    private:
      std::string one, two;
    public:

      DoubleStringHolder(std::string one, std::string two) {
        this->one = one;
        this->two = two;
      }

      DoubleStringHolder() { }

      inline std::string getOne() {
        return this->one;
      }
      inline std::string getTwo() {
        return this->two;
      }
  };
  
  class PrivateConstructor {
    private:
      PrivateConstructor() {}
  };
}

#endif
