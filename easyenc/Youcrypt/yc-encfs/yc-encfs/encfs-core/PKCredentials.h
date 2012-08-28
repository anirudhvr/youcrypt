 /************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_PKCredentials_incl_
#define _Youcrypt_PKCredentials_incl_

#include <string>
#include <vector>
#include "CipherKey.h"
#include "Cipher.h"
#include <boost/shared_ptr.hpp>

using std::string;
using std::vector;

namespace youcrypt {

    class PKCredentials {
    public:
        PKCredentials();
        ~PKCredentials();
        virtual CipherKey decryptVolumeKey(const unsigned char *,
                                           const shared_ptr<Cipher>&);
        virtual void encryptVolumeKey(const CipherKey &,
                                      const shared_ptr<Cipher> &,
                                      unsigned char *);
        virtual int  encodedKeySize(const CipherKey&,
                                    const shared_ptr<Cipher> &);
        virtual bool canEncrypt();
        virtual bool canDecrypt();
    private:
        vector<unsigned char> publicKey, privateKey;
        bool havePub, havePriv;
    };

    typedef boost::shared_ptr<AbstractCredentials> Credentials;
}

#endif

