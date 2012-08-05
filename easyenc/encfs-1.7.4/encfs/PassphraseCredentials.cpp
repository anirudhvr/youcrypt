/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#include "PassphraseCredentials.h"
#include "Cipher.h"

// Helper functions
Cipher::CipherAlgorithm findCipherAlgorithm(const char *name, int keySize );

using std::string;
using youcrypt::PassphraseCredentials;

PassphraseCredentials::PassphraseCredentials(string passphrase) {
    _passphrase = passphrase;
}

//! decrypt a volume key (data) of type (cipher)
CipherKey PassphraseCredentials::decryptVolumeKey(const unsigned char *data, 
                           const boost::shared_ptr<Cipher> &cipher) {
    // Cipher tell us what type of cipher is used in
    // encrypting/decrypting the data.
    CipherKey key = cipher->newKey(_passphrase.c_str(), _passphrase.length());
    return cipher->readKey(data, key, true);
}


//! encrypt volume key (data) using encryption mech. defined by cipher
void PassphraseCredentials::encryptVolumeKey(const CipherKey& key, 
                      const boost::shared_ptr<Cipher> &cipher,
                      unsigned char *data) {
    CipherKey encodingKey = 
        cipher->newKey(_passphrase.c_str(), _passphrase.length());
    cipher->writeKey(key, data, encodingKey);
}




