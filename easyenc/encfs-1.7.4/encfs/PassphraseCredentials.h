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

        virtual CipherKey decryptVolumeKey(const unsigned char *, 
                                           const boost::shared_ptr<Cipher> &);
        virtual void encryptVolumeKey(const CipherKey&, 
                                      const boost::shared_ptr<Cipher> &,
                                      unsigned char *);

    private:
        string _passphrase;    
    };
    
}

#endif

