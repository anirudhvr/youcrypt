/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_Pass_Credentials_incl_
#define _Youcrypt_Pass_Credentials_incl_

#include <string>
#include "Cipher.h"
#include "Credentials.h"
using std::string;
using boost::shared_ptr;

namespace youcrypt {

    class PassphraseCredentials : public AbstractCredentials {
    public:
        PassphraseCredentials(string passphrase);

        virtual CipherKey decryptVolumeKey(const unsigned char *);
        virtual void encryptVolumeKey(const CipherKey &,
                                      unsigned char *);
        virtual int  encodedKeySize(const CipherKey&);

    private:
        string _passphrase;    
        shared_ptr<Cipher> cipher;
    };
    
}

#endif

