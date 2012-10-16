//
//  RSACredentialManager.h
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__RSACredentialManager__
#define __Youcrypt__RSACredentialManager__

#include "core/CredentialsManager.h"

using std::vector;
using std::string;
using boost::shared_ptr;

namespace youcrypt {
    class RSACredentialManager : public CredentialsManager {
    public:
        RSACredentialManager(string privkeyfile, string pubkeyfile, string passphrase, bool create_if_not_found);
        virtual Credentials getActiveCreds();
        virtual CredentialStorage getActiveCredStorage();
        virtual vector<Credentials> getEncodingCreds();
    protected:
        Credentials _cred;
        CredentialStorage _cs;
    };
}


#endif /* defined(__Youcrypt__RSACredentialManager__) */
