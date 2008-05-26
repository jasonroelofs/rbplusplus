#ifndef __SUBCLASS_H__
#define __SUBCLASS_H__
namespace subclass {
  class SuperSuper {
    public:
    inline int minOne() { return -1; }
  };
  class Super : public SuperSuper {
    public:
    inline int zero() { return 0; }
  };
  class Base : public Super {
    public:
    inline int one() { return 1; }
    Base() {}
  };
  class Sub : public Base {
    public:
    Sub() {}
  };
  
  template<class T>
  class TemplateSuper : public Super {
    T val;
    public: 
    TemplateSuper(T val) {
      this->val = val;
    }
    inline T custom() { return this->val; }
  };
  
  class TemplateSub : public TemplateSuper<int> {
    public:
    TemplateSub() : TemplateSuper<int>(0) {}
  };
}
#endif
