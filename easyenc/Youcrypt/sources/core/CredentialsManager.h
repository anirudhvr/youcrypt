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

namespace youcrypt {
    class CredentialsManager {
    public:
        Credentials getActiveCreds();
    };

    shared_ptr<CredentialsManager> getGlobalCM();
    void setGlobalCM(const shared_ptr<CredentialsManager> &);
}

#endif /* defined(__Youcrypt__CredentialsManager__) */
