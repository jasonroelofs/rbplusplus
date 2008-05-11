#ifndef __COMPLEX_H__
#define __COMPLEX_H__

namespace complex {
  class SmallInteger {
  private:
    int i;
  public:
    SmallInteger(int i) {
      this->i = i;
    }
    int getI() {
      return this->i;
    }
  };
  
  class Multiply {
    public:
    static int multiply(SmallInteger *i, SmallInteger *i2) {
      return i->getI() * i2->getI();
    }
  };
}

#endif
