//
//  ProcessQ.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__ProcessQ__
#define __Youcrypt__ProcessQ__

#include <boost/thread/mutex.hpp>
#include <queue>

using boost::mutex;
using std::queue;

namespace youcrypt {
template<class ProcD>
class ProcessQ {
protected:
    mutex _readwriteLock;
    queue<ProcD> _jobs;
    bool _isRunning;
    virtual void doJob(const ProcD &) = 0;
public:
    ProcessQ() { _isRunning = false; }
    void queueJob(const ProcD &);
    void runTillEmpty();
    bool isRunning() { return _isRunning; }
};
}

#endif /* defined(__Youcrypt__ProcessQ__) */
