//
//  PortingQ.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__PortingQ__
#define __Youcrypt__PortingQ__

#include "core/ProcessQ.h"
#include <string>
#include <boost/tuple/tuple.hpp>

using std::string;
using boost::tuple;

namespace youcrypt {

    class EncryptQ : public ProcessQ<string> {
        virtual void doJob(const string &);
    };
    
    class DecryptQ : public ProcessQ<tuple<string, string> > {
        virtual void doJob(const tuple<string, string> &);
    };
    
    class RestoreQ : public ProcessQ<string> {
        virtual void doJob(const string &);
    };
    
    class OpenFileQ : public ProcessQ<string> {
        virtual void doJob(const string &);
    };
}

#endif /* defined(__Youcrypt__PortingQ__) */
