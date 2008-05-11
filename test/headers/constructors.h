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
}

#endif
