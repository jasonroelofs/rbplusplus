namespace encapsulation {
  class Base {
    protected:
      virtual int protectedMethod() {
        return -1;
      }
  };
  
  class Extended {
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
  };
}
