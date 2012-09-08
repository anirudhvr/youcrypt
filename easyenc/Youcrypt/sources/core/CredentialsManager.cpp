//
//  CredentialsManager.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/29/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "CredentialsManager.h"
#include <stdexcept>

using namespace youcrypt;

static shared_ptr<CredentialsManager> theGlobalCM;

namespace youcrypt {
shared_ptr<CredentialsManager> getGlobalCM() {
    if (theGlobalCM)
        return theGlobalCM;
    else
        throw std::runtime_error("Credential Manager not set.");
}

void setGlobalCM(const shared_ptr<CredentialsManager> &cm)
{
    theGlobalCM = cm;
}
}
