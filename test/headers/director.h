#ifndef __DIRECTOR__H__
#define __DIRECTOR__H__

#include <vector>

namespace director {

  /**
   * Abstract base class
   */
  class Worker {
    public:
      virtual ~Worker() {  }

      int getNumber() { return 12; }

      virtual int doSomething(int num) { return num * 4; }
      
      virtual int process(int num) = 0;

      virtual int doProcess(int num) { return doProcessImpl(num); }
      virtual int doProcessImpl(int num) = 0;
  };

  /**
   * Subclass that implements pure virtual
   */
  /*
   * TODO: Is this a valid use case?
  class MultiplyWorker : public Worker {
    public:
      virtual ~MultiplyWorker() { }

      virtual int process(int num) { return num * 2; }
  };
  */

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
  };


  class BadNameClass {
    public:
      BadNameClass() { }

      virtual bool _is_x_ok_to_run() { return false; }

      virtual int __do_someProcessing() { return 14; }
  };

  class VirtualWithArgs {
    int a_;
    bool b_;
    public:
      VirtualWithArgs(int a, bool b) {
        a_ = a;
        b_ = b;
      }

      virtual int processA() {
        return a_;
      }

      virtual bool processB() {
        return b_;
      }
  };

  class NoConstructor {
    protected:
      NoConstructor() { }
      NoConstructor(const NoConstructor&) { }

    public:
      virtual int doSomething() { return 4; }
  };

}

#endif
