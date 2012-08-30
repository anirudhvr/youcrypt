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

#include "yc_openssl_rsaapps.h"

using std::string;
using boost::shared_ptr;
using boost::unordered_map;
using std::map;

#define MAX_RSA_CIPHERTEXT_LENGTH 256

namespace youcrypt {
    
    struct RSACredentialStorage : public AbstractCredentialStorage {
        static const string RSA_PRIVKEYFILE_KEY, RSA_PUBKEYFILE_KEY;
        
        RSACredentialStorage(string privkeyfile, string pubkeyfile,
                             const map<string, string> &otherparams);
        virtual string getCredData(const string credName);
        bool checkCredentials(string passphrase);
        bool createKeys(string passphrase);
        enum Status {
            PrivKeyFound = 0,
            PrivKeyNotFound,
            PrivKeyCreateError,
            PrivKeyReadError,
            PubKeyCreateError,
            KeyCreateSuccess,
            KeyReadSuccess
        };
        Status status() { return _status; }
        
    private:
        
        Status _status;
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
    private:
        string _passphrase;
        CredentialStorage _cstore;
    };
    
}

#endif /* defined(__yc_encfs__RSACredential__) */
