//
//  CredentialsManager.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/29/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__CredentialsManager__
#define __Youcrypt__CredentialsManager__

#include "encfs-core/Credentials.h"
#include <vector>
#include <boost/shared_ptr.hpp>

using std::vector;
using boost::shared_ptr;

namespace youcrypt {
    class CredentialsManager {
    public:
        virtual Credentials getActiveCreds()=0;
        virtual vector<Credentials> getEncodingCreds()=0;
    };

    shared_ptr<CredentialsManager> getGlobalCM();
    void setGlobalCM(const shared_ptr<CredentialsManager> &);
}

#endif /* defined(__Youcrypt__CredentialsManager__) */
