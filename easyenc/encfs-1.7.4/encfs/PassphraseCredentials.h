/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_Pass_Credentials_incl_
#define _Youcrypt_Pass_Credentials_incl_

#include <string>
#include "Credentials.h"
using std::string;

namespace youcrypt {

    class PassphraseCredentials : public Credentials {
    public:
        PasswordCredentials(string passphrase);
        virtual CipherKey decryptVolumeKey(const unsigned char *);
    private:
        string _passphrase;
    };
    
}

#endif

