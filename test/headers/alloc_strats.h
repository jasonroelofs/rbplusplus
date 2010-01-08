#ifndef __ALLOC_STRATS_H__
#define __ALLOC_STRATS_H__

namespace alloc_strats {

  class NoConstructor {
    public:
      ~NoConstructor() { }

    private:
      NoConstructor() { }
  };

  class Neither {
    private:
      Neither() {}
      ~Neither() {}
    public:
      NoConstructor* getConstructor() { return 0; }

      static Neither* getInstance() { static Neither neither; return &neither; }

      int process(int a, int b) { return a * b; }
  };
}


#endif
