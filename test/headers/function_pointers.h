/**
 * Code to wrap and handle function callbacks by exposing them
 * into Ruby as block arguments
 */
#ifndef __FUNCTION_POINTERS_H__
#define __FUNCTION_POINTERS_H__

namespace function_pointers {

  // One that takes no argument, no return
  typedef void(*Callback) (void);
  Callback emptyCallback;

  void setCallback(Callback cb) { emptyCallback = cb; }
  void callCallback() { emptyCallback(); }

  // With an argument, no return
  typedef void(*ArgCallback) (int num);
  ArgCallback argumentCallback;

  void setCallbackWithArgs(ArgCallback cb) { argumentCallback = cb; }
  void callCallbackWithArgs(int in) { argumentCallback(in); }

  // With argument and returns a value
  typedef int(*ReturnCallback) (int num);
  ReturnCallback returnCallback;

  void setCallbackReturns(ReturnCallback cb) { returnCallback = cb; }
  int callCallbackReturns(int in) { return returnCallback(in); }
}

#endif
