#ifndef __CONSTRUCTORS_H__
#define __CONSTRUCTORS_H__

#include <string>

using namespace std;

namespace constructors {
  class StringHolder {
    private:
      std::string name;
    public:
      StringHolder() { }
      StringHolder(std::string name) {
        setName(name);
      }
      inline std::string getName() {
        return name;
      }
      inline void setName(std::string name) {
        this->name = name;
      }
  };
  
  class DoubleStringHolder {
    private:
      StringHolder *one, *two;
    public:
      DoubleStringHolder(StringHolder *one, StringHolder *two) {
        this->one = one;
        this->two = two;
      }
      inline StringHolder *getOne() {
        return this->one;
      }
      inline StringHolder *getTwo() {
        return this->two;
      }
  };
}

#endif
