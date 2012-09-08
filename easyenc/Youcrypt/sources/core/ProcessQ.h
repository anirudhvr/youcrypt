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
#include <boost/thread/locks.hpp>
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
    int size() {
        return _jobs.size();
    }
    void queueJob(const ProcD &newJob) {
        mutex::scoped_lock lock(_readwriteLock);
        _jobs.push(newJob);
    }
    void runTillEmpty() {
        { mutex::scoped_lock lock(_readwriteLock);
            if (isRunning()) return;
            _isRunning = true;
        }
        ProcD currJob;
        while (_isRunning) {
            {
                mutex::scoped_lock lock(_readwriteLock);
                if (_jobs.size() == 0)
                    _isRunning = false;
                else {
                    currJob = _jobs.front();
                    _jobs.pop();
                }
            }
            if (_isRunning)
                doJob(currJob);
        }
    }
 
    bool isRunning() { return _isRunning; }
};
}

#endif /* defined(__Youcrypt__ProcessQ__) */
