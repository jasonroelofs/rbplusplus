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

      Neither* getInstance() { return 0; }
  };
}


#endif
