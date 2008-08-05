#ifndef __ADDER_H__
#define __ADDER_H__

#include <string>
using namespace std;

namespace classes {
  class Adder {
    public:
      Adder() { }

      static int doAdding(int a, int b, int c, int d, int e) {
        return a + b + c + d + e;
      }

      int addIntegers(int a, int b) { return a + b; }

      float addFloats(float a, float b) { return a + b; }

      string addStrings(string a, string b) { return a + b; }

      string getClassName() { return "Adder"; }
  };

  template<typename T>
  class TemplateAdder {

  };

  typedef TemplateAdder<int> IntAdder;
}

#endif 
