#ifndef __SUBTRACTER_H__
#define __SUBTRACTER_H__

#include <string>
using namespace std;

namespace subtracter {
  class Subtracter {
    public:
      Subtracter() { }

      int subIntegers(int a, int b) { return a - b; }

      float subFloats(float a, float b) { return a - b; }

      string getClassName() { return "Subtracter"; }
  };
}

#endif 
