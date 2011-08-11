#ifndef __MY_TYPE_H__
#define __MY_TYPE_H__

class MyType {
  int myValue;

  public:
  MyType() { myValue = 0; }

  // Exposing attributes not implemented yet
  int value() const { return myValue; }

  void setValue(int value) { myValue = value; }
};

#endif
