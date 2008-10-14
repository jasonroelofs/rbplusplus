#ifndef __ALLOC_STRATS_H__
#define __ALLOC_STRATS_H__

namespace alloc_strats {
  /**
   * Why this case could every a good idea, 
   * or even possible, I have no idea, but
   * what the hell, it helps with understanding
   * what allocation_strategy does
   */
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
