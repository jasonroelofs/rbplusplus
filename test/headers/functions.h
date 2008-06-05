/**
 * This header file is for testing free (top) level function
 * parsing and querying
 */

#ifndef __FUNCTIONS__H__
#define __FUNCTIONS__H__

typedef void* Callback;

namespace functions {

  void test1() { }

  float test2(int arg1) {  return 1.0; }

  int test3(int arg1, float arg2) { return arg1; }
  
  void * voidStar()  { return 0; }

  void takesVoidStar(void *arg) { }
  
  Callback typedefedVoidStar() {return 0;}
}

#endif
