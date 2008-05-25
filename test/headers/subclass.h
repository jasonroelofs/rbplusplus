#ifndef __SUBCLASS_H__
#define __SUBCLASS_H__
namespace subclass {
  class Base {
    public:
    inline int one() { return 1; }
    Base() {}
  };
  class Sub : public Base {
    public:
    Sub() {}
  };  
}
#endif
