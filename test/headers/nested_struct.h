#ifndef __NESTED_STRUCT_H
#define __NESTED_STRUCT_H

namespace nested {
  class Klass {
    public:
      struct NestedStruct {
        public:
          NestedStruct() {}
          inline int one() { return 1; }
      };
    private:
      struct PrivateNestedStruct {
        public:
          PrivateNestedStruct() {}
      };
  };
}

#endif
