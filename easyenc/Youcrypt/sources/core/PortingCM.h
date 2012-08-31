//
//  PortingCM.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__PortingCM__
#define __Youcrypt__PortingCM__

#include "CredentialsManager.h"

using std::vector;
using boost::shared_ptr;

namespace youcrypt {
    class PortingCM : public CredentialsManager {
    public:
        virtual Credentials getActiveCreds();
        virtual vector<Credentials> getEncodingCreds();
        void setPassphrase(string);
    protected:
        Credentials _thePPCred;
    };
}


#endif /* defined(__Youcrypt__PortingCM__) */
