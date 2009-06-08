#ifndef __ADDER_H__
#define __ADDER_H__

#include <string>
using namespace std;

namespace classes {
  class Adder {
    public:
      Adder();

      static const int MY_VALUE;

      static const float HideMe;

      static int doAdding(int a, int b, int c, int d, int e) {
        return a + b + c + d + e;
      }

      int addIntegers(int a, int b) { return a + b; }

      float addFloats(float a, float b) { return a + b; }

      string addStrings(string a, string b) { return a + b; }

      string getClassName() { return "Adder"; }

      int value1;
      float value2;
      string value3;

      string shouldBeTransformed;

      const int const_var;
  };

  template<typename T>
  class TemplateAdder {

  };

  typedef TemplateAdder<int> IntAdder;

  template<typename T>
  class NestedTemplate {

  };

  typedef NestedTemplate<int> SuperTemplate;
  typedef SuperTemplate MiddleTypedef;
  typedef MiddleTypedef ShouldFindMe;

  typedef Adder DontFindMeBro;
}

#endif 
