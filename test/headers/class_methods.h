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
}
