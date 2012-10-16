//
//  RSACredentialManager.cpp
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "RSACredentialManager.h"
#include "encfs-core/Credentials.h"
#include "encfs-core/PassphraseCredentials.h"
#include "encfs-core/RSACredentials.h"
#include <map>
#include <stdexcept>

using namespace youcrypt;

namespace youcrypt {
    
    RSACredentialManager::RSACredentialManager(string privkeyfile, string pubkeyfile, string passphrase, bool create_if_not_found)
    {
        map<string,string> empty;
        _cs.reset(new RSACredentialStorage(privkeyfile, pubkeyfile, empty));
        if (_cs->checkCredentials(passphrase, create_if_not_found)) {
            _cred.reset(new RSACredentials(passphrase, _cs));
        } else {
            throw std::runtime_error("Passphrase cannot decrypt private key");
        }
    }
    
    Credentials RSACredentialManager::getActiveCreds() {
        return _cred;
    }
    vector<Credentials> RSACredentialManager::getEncodingCreds() {
        vector<Credentials> v;
        v.push_back(_cred);
        return v;
    }
    
    CredentialStorage RSACredentialManager::getActiveCredStorage() {
        return _cs;
    }
    
}

