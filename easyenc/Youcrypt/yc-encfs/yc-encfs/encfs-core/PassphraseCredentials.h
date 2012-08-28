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
#include "CipherKey.h"

using std::string;
using boost::shared_ptr;

namespace youcrypt {

    class PassphraseCredentials : public AbstractCredentials {
    public:
        PassphraseCredentials(string passphrase);

        virtual CipherKey decryptVolumeKey(const KeydataType &,
                                           const shared_ptr<Cipher>&);
        virtual void encryptVolumeKey(const CipherKey &,
                                      const shared_ptr<Cipher> &,
                                      KeydataType &);

    private:
        string _passphrase;    
        shared_ptr<Cipher> cipher;
        CipherKey masterKey;
    };
    
}

#endif

