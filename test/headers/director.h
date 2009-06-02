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
  };

}

#endif
