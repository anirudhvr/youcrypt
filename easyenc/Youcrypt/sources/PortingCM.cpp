//
//  PortingCM.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "PortingCM.h"
#include "encfs-core/Credentials.h"
#include "encfs-core/PassphraseCredentials.h"

using namespace youcrypt;

namespace youcrypt {
    Credentials PortingCM::getActiveCreds() {
        return _thePPCred;
    }
    vector<Credentials> PortingCM::getEncodingCreds() {
        vector<Credentials> v;
        v.push_back(_thePPCred);
        return v;
    }
    void PortingCM::setPassphrase(string p) {
        _thePPCred.reset(new PassphraseCredentials(p));
    }
}

