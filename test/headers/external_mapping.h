#ifndef EXTERNAL_INCLUDE_TEST
#define EXTERNAL_INCLUDE_TEST

namespace ExternalIncludeTest {
  class MapsToInt {
    public:
      MapsToInt(int x) {value=x;}
      int value;
  };
  inline MapsToInt return100() {
    return MapsToInt(100);
  }

}

#endif
