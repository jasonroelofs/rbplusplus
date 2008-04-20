#ifndef __NESTED_CLASSES_H__
#define __NESTED_CLASSES_H__

namespace classes {
  class TestClass {
    public: 
      TestClass() {  }

      class InnerClass {
        public:
          InnerClass() {}
          class Inner2 {
            public:
              Inner2() {}
          };
      };
  };
}

#endif
