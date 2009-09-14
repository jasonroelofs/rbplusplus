#ifndef __METHOD_OVERLOAD_H__
#define __METHOD_OVERLOAD_H__

namespace overload {
  class Mathy {
    public:
    Mathy() {}
    Mathy(int x) {}
    int times() {
      return 1;
    }
    int times(int x) {
      return x;
    }
    int times(int x, int y) {
      return x*y;
    }
    long times(int x, int y, int z) {
      return x*y*z;
    }
    void nothing() {}
    void nothing(int x) {}
  };
}
#endif
