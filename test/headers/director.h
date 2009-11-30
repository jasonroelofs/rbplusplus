#ifndef __DIRECTOR__H__
#define __DIRECTOR__H__

#include <vector>
#include <string>

namespace director {

  /**
   * Abstract base class
   */
  class Worker {
    public:
      virtual ~Worker() {  }

      enum ZeeEnum {
        VALUE = 4
      };

      int getNumber() { return 12; }

      virtual int doSomething(int num) { return num * 4; }
      
      virtual int process(int num) = 0;

      virtual int doProcess(int num) { return doProcessImpl(num); }
      virtual int doProcessImpl(int num) const = 0;
  };

  /**
   * Subclass that implements pure virtual
   */
  class MultiplyWorker : public Worker {
    public:
      virtual ~MultiplyWorker() { }

      virtual int process(int num) { return num * 2; }
  };

  /**
   * Class to handle workers
   */
  class Handler {
    std::vector<Worker*> mWorkers;

    public:

      void addWorker(Worker* worker) { mWorkers.push_back(worker); }

      int processWorkers(int start) {
        std::vector<Worker*>::iterator i = mWorkers.begin();
        int results = start;

        for(; i != mWorkers.end(); i++) {
          results = (*i)->process(results);
        }

        return results;
      }

      int addWorkerNumbers() {
        std::vector<Worker*>::iterator i = mWorkers.begin();
        int results = 0;

        for(; i != mWorkers.end(); i++) {
          results += (*i)->getNumber();
        }

        return results;
      }
  };


  /**
   * Testing renaming works w/ directors
   */
  class BadNameClass {
    public:
      BadNameClass() { }

      virtual bool _is_x_ok_to_run() { return false; }

      virtual int __do_someProcessing() { return 14; }
  };

  /**
   * Testing constructor args
   */
  class VirtualWithArgs {
    int a_;
    bool b_;
    public:
      VirtualWithArgs(int a, bool b) {
        a_ = a;
        b_ = b;
      }

      virtual int processA(std::string in) {
        return in.length() + a_;
      }

      virtual bool processB() {
        return b_;
      }
  };

  /**
   * Testing non-public constructors
   */
  class NoConstructor {
    protected:
      NoConstructor() { }
      NoConstructor(const NoConstructor&) { }

    public:
      virtual int doSomething() { return 4; }
  };

  /**
   * Test inheritance heirarchy with virtual methods
   * throughout the tree
   */
  class VBase {
    public:
      VBase() { }
      virtual ~VBase() { }

      /**
       * See that types are registered properly.
       * Passing a VTwo into this method should work
       */
      static std::string process(VBase* base) {
        return base->methodTwo();
      } 

      virtual std::string methodOne() = 0;
      virtual std::string methodTwo() = 0;
      virtual std::string methodThree() = 0;
  };

  class VOne : public VBase { 
    public:
      virtual std::string methodOne() {
        return "methodOne";
      }
  };

  class VTwo : public VOne {
    public:
      virtual std::string methodTwo() {
        return "methodTwo";
      }
  };
}

#endif
