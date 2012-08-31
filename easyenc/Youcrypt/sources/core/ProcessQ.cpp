//
//  ProcessQ.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "ProcessQ.h"

#include <boost/thread/locks.hpp>

using boost::mutex;
using namespace youcrypt;

namespace youcrypt {
    template<class P>
    void ProcessQ<P>::queueJob(const P& newJob) {
        mutex::scoped_lock lock(_readwriteLock);
        _jobs.push(newJob);
    }

    template<class P>
    void ProcessQ<P>::runTillEmpty() {
        if (isRunning()) return;
        P currJob;
        while (_isRunning) {
            {
                mutex::scoped_lock lock(_readwriteLock);
                if (_jobs.size() == 0)
                    _isRunning = false;
                else {
                    currJob = _jobs.pop();
                }
            }
            if (_isRunning)
                doJob(currJob);
        }
    }

}
