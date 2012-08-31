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

using std::string;

namespace youcrypt {

    class EncryptQ : public ProcessQ<string> {
        virtual void doJob(const string &);
    };        
}

#endif /* defined(__Youcrypt__PortingQ__) */
