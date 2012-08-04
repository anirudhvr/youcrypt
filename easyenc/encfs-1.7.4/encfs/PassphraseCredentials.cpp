/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#include "PassphraseCredentials.h"

using std::string;
using youcrypt::PassphraseCredentials;

PassphraseCredentials::PasswordCredentials(string passphrase) {
    _passphrase = passphrase;

    // Initialize masterKey here.
    // Initialize cipher here.

    // FIXME:  Harcoded (256bits, AES key)
    int keySize = 256;
    Cipher::CipherAlgorithm alg = findCipherAlgorithm("AES", keySize);
    keyCipher = Cipher::New ( alg.name, keySize );
}

CipherKey PassphraseCredentials::decryptVolumeKey(const unsigned char* encKey) {
    
}

void Passphrase::Credentials::encryptVolumeKey(unsigned char* data) {
}



