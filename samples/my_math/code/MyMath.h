// My Math example showing the simplest in rb++ wrapping

// All wrapped code needs a namespace. This allows rb++ to differentiate
// between the code to be wrapped and system declarations like from
// STL
#include <stdlib.h>
#include <time.h>

namespace my_math {
  
  class MyMath {
    public:
      MyMath() { 
        srand(time(NULL));
        mSecret = 410 + rand() * 300; 
      }

      // Basic methods are wrapped directly
      int abs(int in) {
        if (in < 0) {
          return in * -1;
        } else {
          return in;
        }
      }

      int fib(int in) {
        if (in > 1) {
          return fib(in - 1) + fib(in - 2);
        } else {
          return in;
        }
      }

      // Method names are auto underscored when wrapped into Ruby
      int secretNumber() {
        return mSecret;
      }

    private:
      int mSecret;
  };
}
