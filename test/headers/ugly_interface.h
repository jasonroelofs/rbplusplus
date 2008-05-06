#ifndef __UGLY_H__
#define __UGLY_H__

/*
Mapping should work for:
ruby:
F = function
M = module
C = class

c++:
m = namespace
f = function
c = class

  m f c
F   x 
M x x x
C   x x

*/

//should be exported as UI::add
inline int uiAdd(int a, int b) {
  return a+b;
}


//should be exported as UI::subtract
inline int ui_Subtract(int a, int b) {
  return a-b;
}

inline void uiIgnore() {}

class C_UIVector {
  private:
    int x;
  public:
    int x_() {
      return this->x;
    }
    void set_X(int x) {
      this->x = x;
    }
};

namespace __UI {
  namespace BAD_UI {
    inline int multiply(int a, int b) {
      return a*b;
    }
  }
}

struct C_STRUCT_Quaternion {
  public:
    int i() {
      return -1;
    }
};

#endif
