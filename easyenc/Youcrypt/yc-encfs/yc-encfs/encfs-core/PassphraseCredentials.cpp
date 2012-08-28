/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#include "PassphraseCredentials.h"
#include "Cipher.h"
#include <boost/scoped_ptr.hpp>

// Helper functions
Cipher::CipherAlgorithm findCipherAlgorithm(const char *name, int keySize );

using std::string;
using youcrypt::PassphraseCredentials;
using boost::scoped_ptr;

const int KEY_CHECKSUM_BYTES = 4;

PassphraseCredentials::PassphraseCredentials(string passphrase) {
    _passphrase = passphrase;
    int keySize = 256;
    Cipher::CipherAlgorithm alg = findCipherAlgorithm("AES", keySize);    
    cipher = Cipher::New(alg.name, keySize);
    masterKey = cipher->newKey(_passphrase.c_str(), 
                               _passphrase.length());
}

//! decrypt a volume key (data) of type (cipher)
CipherKey PassphraseCredentials::decryptVolumeKey(
    const vector<unsigned char> &data,
    const shared_ptr<Cipher> &kc)
{
    // Cipher tell us what type of cipher is used in
    // encrypting/decrypting the data.
    if (!cipher || !masterKey || 
        (data.size() != kc->encodedKeySize() + KEY_CHECKSUM_BYTES))
        return CipherKey();
    
    // Process data, and check sum
    unsigned int checksum = 0;
    for(int i=0; i<KEY_CHECKSUM_BYTES; ++i) {
        checksum <<= 8;
        checksum |= (unsigned int)data[i];
    }
    
    int bufLen = kc->encodedKeySize();
    scoped_ptr<unsigned char> tmpBuf(new unsigned char[bufLen]);
    std::copy(data.begin()+KEY_CHECKSUM_BYTES, data.end(), tmpBuf.get());
    cipher->streamDecode(tmpBuf.get(), bufLen, checksum, masterKey);
    unsigned int checksum2 = cipher->MAC_32(tmpBuf.get(),
                                            bufLen,
                                            masterKey);
    if (checksum2 != checksum)
        return CipherKey();
    else
        return kc->readRawKey(tmpBuf.get(), true);
}


//! encrypt volume key (data) using encryption mech. defined by cipher
void PassphraseCredentials::encryptVolumeKey(
    const CipherKey& key, 
    const boost::shared_ptr<Cipher> &keyCipher,
    vector<unsigned char> &data) {

    int bufLen = keyCipher->encodedKeySize();
    data.resize(bufLen + KEY_CHECKSUM_BYTES);
    unsigned char *tmpBuf = &(data.front());
    tmpBuf += KEY_CHECKSUM_BYTES;
    keyCipher->writeRawKey(key, tmpBuf);
    unsigned int checksum = cipher->MAC_32(tmpBuf,
                                           bufLen,
                                           masterKey);
    cipher->streamEncode(tmpBuf, bufLen, checksum, masterKey);
    for (int i=1; i<=KEY_CHECKSUM_BYTES; ++i)
    {
        data[KEY_CHECKSUM_BYTES-i] = checksum & 0xff;
        checksum >>= 8;
    }
}



