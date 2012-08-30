/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_Credentials_incl_
#define _Youcrypt_Credentials_incl_

#include <string>
#include <vector>
#include "CipherKey.h"
#include "Cipher.h"
#include <boost/shared_ptr.hpp>

using std::string;
using std::vector;
using boost::shared_ptr;

namespace youcrypt {

    class AbstractCredentials {
    public:
        typedef vector<unsigned char> KeydataType;
        virtual CipherKey decryptVolumeKey(const KeydataType &,
                                           const shared_ptr<Cipher>&) = 0;
        virtual void encryptVolumeKey(const CipherKey &,
                                      const shared_ptr<Cipher> &,
                                      KeydataType &) = 0;
        //! Obsolete
        virtual int  encodedKeySize(const CipherKey&,
                                    const shared_ptr<Cipher> &);
    };
    

    typedef boost::shared_ptr<AbstractCredentials> Credentials;
    
    
    struct AbstractCredentialStorage {
        enum CRED_TYPE {
            CRED_TYPE_PASSPHRASE = 0,
            CRED_TYPE_RSA,
            CRED_TYPE_DSA
        };
        
        virtual string getCredData(string credName) = 0;
        virtual bool checkCredentials(string passphrase) = 0;
    };
    
    typedef boost::shared_ptr<AbstractCredentialStorage> CredentialStorage;
}

#endif

