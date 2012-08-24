/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_Credentials_incl_
#define _Youcrypt_Credentials_incl_

#include <string>
#include "CipherKey.h"
#include "Cipher.h"
#include <boost/shared_ptr.hpp>

using std::string;

namespace youcrypt {

    class AbstractCredentials {
    public:
        virtual CipherKey decryptVolumeKey(const unsigned char *) = 0;
        virtual void encryptVolumeKey(const CipherKey &,
                                      unsigned char *) = 0;
        virtual int  encodedKeySize(const CipherKey&) = 0;
    };

    typedef boost::shared_ptr<AbstractCredentials> Credentials;
}

#endif

