//
//  RSACredential.cpp
//  yc-encfs
//
//  Created by avr on 8/27/12.
//  Copyright (c) 2012 avr. All rights reserved.
//

#include "RSACredentials.h"
#include "Cipher.h"
#include <boost/scoped_ptr.hpp>
#include <string.h>

using std::string;
using namespace youcrypt;
using boost::scoped_ptr;
using boost::unordered_map;


RSACredentials::RSACredentials(string passphrase, CredentialStorage &cstore) :
_passphrase(passphrase), _cstore(cstore)
{ }

//! return encoded key size
int RSACredentials::encodedKeySize(const CipherKey &key,
                                   const shared_ptr<Cipher> &c) {
    return MAX_RSA_CIPHERTEXT_LENGTH;
}

//! encrypt volume key (data) using encryption mech. defined by cipher
void RSACredentials::encryptVolumeKey(const CipherKey& key, 
                      const boost::shared_ptr<Cipher> &keyCipher,
                      unsigned char *data) {
    
    int bufLen = keyCipher->encodedKeySize();
    unsigned char *tmpBuf = new unsigned char [bufLen], *cipher = NULL;
    keyCipher->writeRawKey(key, tmpBuf);
    struct rsautl_args rsaargs;
    char *pubkeyfilename = strdup(_cstore->getCredData(RSA_PUBKEYFILE_KEY).c_str());
    
    rsaargs.inbuf = tmpBuf;
    rsaargs.insize = bufLen;
    rsaargs.outsize = 0;
    
    char *rsautl_encrypt_argv[] = {"rsautl", "-encrypt",
        "-inkey", pubkeyfilename,
        "-pubin",
//        "-in", "/tmp/plain.txt",
//        "-out", "/tmp/cipher.txt",
         "-inbuf"
    };

    rsautl(6, rsautl_encrypt_argv,
           &rsaargs);
    
    if (pubkeyfilename) free(pubkeyfilename);
    
    if (rsaargs.outsize > 0) { // something got written
        memcpy(data, *rsaargs.outbuf, rsaargs.outsize);
        memset((data + rsaargs.outsize),
               0,
               (MAX_RSA_CIPHERTEXT_LENGTH - rsaargs.outsize));
    } else {
        memset(data, 0,
               MAX_RSA_CIPHERTEXT_LENGTH);
        std::cerr << "Shit's all fucked up, yo" << std::endl;
    }

    
}


//! decrypt a volume key (data) of type (cipher)
CipherKey RSACredentials::decryptVolumeKey(const unsigned char *data,
                                           const shared_ptr<Cipher> &kc)
{
    // XXX <- Not a good idea to guess 'data's size this way
    int bufLen = MAX_RSA_CIPHERTEXT_LENGTH;
    
    struct rsautl_args rsaargs;
    char *privkeyfilename = strdup(_cstore->getCredData(RSA_PRIVKEYFILE_KEY).c_str());
    string passwordarg("pass:");
    passwordarg += _passphrase;
    char *pwarg = strdup(passwordarg.c_str());
    
    rsaargs.inbuf = const_cast<unsigned char*>(data);
    rsaargs.insize = 128; // XXX FIXME
    rsaargs.outsize = 0;
    char *rsautl_decrypt_argv[] = {"rsautl",
        "-decrypt",
        "-passin", "pass:asdfgh", // pwarg, 
        "-inkey", privkeyfilename,
        "-inbuf"
        // "-in", "cipher.txt", "-out", "plain2.txt",
        };
    
    rsautl(7, rsautl_decrypt_argv, &rsaargs);
    
    if (pwarg) free(pwarg);
    if (privkeyfilename) free(privkeyfilename);
    
    return kc->readRawKey(*rsaargs.outbuf, true);
    
//    // encrypting/decrypting the data.
//    if (cipher && masterKey) {
//        // Process data, and check sum
//        unsigned int checksum = 0;
//        for(int i=0; i<KEY_CHECKSUM_BYTES; ++i) {
//            checksum <<= 8;
//            checksum |= (unsigned int)data[i];
//        }
//        int bufLen = kc->encodedKeySize();
//        scoped_ptr<unsigned char> tmpBuf(new unsigned char[bufLen]);
//        memcpy(tmpBuf.get(), data+KEY_CHECKSUM_BYTES, bufLen);
//        cipher->streamDecode(tmpBuf.get(), bufLen, checksum, masterKey);
//        unsigned int checksum2 = cipher->MAC_32(tmpBuf.get(),
//                                                bufLen,
//                                                masterKey);
//        if (checksum2 != checksum)
//            return CipherKey();
//        else
//            return kc->readRawKey(tmpBuf.get(), true);
//    }
//    else
//        return CipherKey();
//    return CipherKey();
}



RSACredentialStorage::RSACredentialStorage(string &privkeyfile, string &pubkeyfile,
                                           unordered_map<string, string> &otherparams)
: _creds(otherparams)
{
    _creds[RSA_PRIVKEYFILE_KEY] = privkeyfile;
    _creds[RSA_PUBKEYFILE_KEY] = pubkeyfile;
}

string
RSACredentialStorage::getCredData(const string credname)
{
    unordered_map<string, string>::iterator map_it;
    map_it = _creds.find(credname);
    if (map_it == _creds.end())
        return string();
    else
        return map_it->second;
}
