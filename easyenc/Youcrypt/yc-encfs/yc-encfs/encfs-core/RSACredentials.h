//
//  RSACredential.h
//  yc-encfs
//
//  Created by avr on 8/27/12.
//  Copyright (c) 2012 avr. All rights reserved.
//

#ifndef __yc_encfs__RSACredential__
#define __yc_encfs__RSACredential__

#include <iostream>
#include <string>
#include "Cipher.h"
#include "Credentials.h"
#include "CipherKey.h"

#include <boost/unordered_map.hpp>
#include <map>

extern "C" {
#include "yc_openssl_rsaapps.h"
}

using std::string;
using boost::shared_ptr;
using boost::unordered_map;
using std::map;

// XXX FIXME HACK - because we don't know how mcuh the ciphertext will be
// in advance. To fix this, have encryptVolumeKey return vector<char> so
// we can get rid of encodedKeySize
#define MAX_RSA_CIPHERTEXT_LENGTH 256 // Safe max for a 52-byte plaintext

const string RSA_PRIVKEYFILE_KEY = "__yc_rsaprivkeyfile";
const string RSA_PUBKEYFILE_KEY = "__yc_rsapubkeyfile";

namespace youcrypt {
    
    struct RSACredentialStorage : public AbstractCredentialStorage {
        
        RSACredentialStorage(string privkeyfile, string pubkeyfile,
                             const map<string, string> &otherparams);
        virtual string getCredData(const string credName);
        virtual ~RSACredentialStorage()
        {
            _creds.clear();
        }
        
    private:
        map<string, string> _creds;
    };

    class RSACredentials : public AbstractCredentials {
    public:
        RSACredentials(string passphrase, const CredentialStorage &cstore);

        virtual CipherKey decryptVolumeKey(const vector<unsigned char> &,
                                           const shared_ptr<Cipher>&);
        virtual void encryptVolumeKey(const CipherKey &,
                                      const shared_ptr<Cipher> &,
                                      vector<unsigned char> &);
        virtual ~RSACredentials() {
            
        }
        
    private:
        string _passphrase;
        CredentialStorage _cstore;
    };
    
}

#endif /* defined(__yc_encfs__RSACredential__) */
