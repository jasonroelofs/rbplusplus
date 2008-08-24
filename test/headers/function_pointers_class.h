namespace function_pointers_class {
  
  // With argument and returns a value
  typedef int(*Callback) (int num);

  class PointerTest {
    public:
      PointerTest() {}

      void setCallback(Callback cb) {
        mCallback = cb;
      }

      int callCallback(int num) {
        return mCallback(num);
      }

    private:
      Callback mCallback;
  };
}
