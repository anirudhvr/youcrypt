//
//  CredentialsManager.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/29/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "CredentialsManager.h"

using namespace youcrypt;

static shared_ptr<CredentialsManager> theGlobalCM;

namespace youcrypt {
shared_ptr<CredentialsManager> getGlobalCM() {
    return theGlobalCM;
}

void setGlobalCM(const shared_ptr<CredentialsManager> &cm)
{
    theGlobalCM = cm;
}
}
