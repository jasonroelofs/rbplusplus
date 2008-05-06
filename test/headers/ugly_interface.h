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
F    
M x x x
C   x 

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
    C_UIVector() {}
    int x_() {
      return this->x;
    }
    void set_X(int x) {
      this->x = x;
    }
};


namespace __UI {
  namespace BAD_UI {
    class Multiplier {
    public:
      Multiplier() {}
      inline int multiply(int a, int b) {
        return a*b;
      }
    };
    inline int multiply(int a, int b, int c) {
      return a*b*c;
    }
  }
}

namespace DMath {
  inline float divide(float a,float b) {
    return a/b;
  }
}

struct C_STRUCT_Quaternion {
  public:
    int i() {
      return -1;
    }
};

namespace I_LEARN_C {
    inline int mod(int a, int b) {
      return a%b;
    }
    class Modder {
    public:
      Modder() {}
      
    };
} 

#endif
