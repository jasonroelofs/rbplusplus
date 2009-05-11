#ifndef __ENCAPSULATE_H__
#define __ENCAPSULATE_H__

namespace encapsulation {
  class Base {
    protected:
      virtual int protectedMethod() {
        return -1;
      }
    public:
      virtual int fundamentalTypeVirtualMethod() = 0;
      virtual ~Base() {}
      virtual Base *userDefinedTypeVirtualMethod() = 0;
  };
  
  class Extended : public Base {
    private:
      void privateMethod() {
      }
    protected:
      int protectedMethod() {
        return 1;
      }
    public:
      Extended() {}
      int publicMethod() {
        return this->protectedMethod();
      }
      int fundamentalTypeVirtualMethod() {
        return 1;
      }
      Base *userDefinedTypeVirtualMethod() {
        return new Extended();
      }
  };
  
  class ExtendedFactory {
  public:
    ExtendedFactory() {}
    Base *newInstance() {
      return new Extended();
    }
  };

  class ArgumentAccess {
    struct PrivateStruct { }; 

  protected:
    struct ProtStruct { };

  public:
    struct PublicStruct { 
      PublicStruct() {}
    };

    ArgumentAccess() {}
    ~ArgumentAccess() {}

    // Only wrap methods that use public structs
    void wrapMePrivate(PrivateStruct st) { }
    void wrapMeProtected(ProtStruct st) { }
    void wrapMePublic(PublicStruct st) { }

    // And make sure it works with multiple arguments
    void wrapMeManyNo(int a, float b, PublicStruct st1, ProtStruct st2) { }
    void wrapMeManyYes(int a, float b, PublicStruct st1) { }

  };
}

#endif
