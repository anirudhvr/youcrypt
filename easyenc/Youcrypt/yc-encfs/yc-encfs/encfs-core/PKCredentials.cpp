/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_PKCredentials_incl_
#define _Youcrypt_PKCredentials_incl_

#include <string>
#include "CipherKey.h"
#include "Cipher.h"
#include <boost/shared_ptr.hpp>

using std::string;
using namespace youcrypt;

PKCredentials::PKCredentials() {
    havePub = havePriv = false;
}

PKCredentials::~PKCredentials() {
}

bool PKCredentials::canEncrypt() {
    return havePub;
}

bool PKCredentials::canDecrypt() {
    return havePriv;
}

CipherKey PKCredentials::decryptVolumeKey(const unsigned char *,
                                          const shared_ptr<Cipher>&) {
    return CipherKey();
}

void PKCredentials::encryptVolumeKey(const CipherKey &,
                                     const shared_ptr<Cipher> &,
                                     unsigned char *) {
}

int PKCredentials::encodedKeySize(const CipherKey&,
                                  const shared_ptr<Cipher> &) {
    return 0;
}

#endif

