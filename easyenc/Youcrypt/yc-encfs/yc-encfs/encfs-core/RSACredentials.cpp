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
#include <boost/filesystem.hpp>
#include <string.h>

using std::string;
using namespace youcrypt;
using boost::scoped_ptr;
using boost::shared_ptr;
using boost::unordered_map;
namespace fs = boost::filesystem;


RSACredentials::RSACredentials(string passphrase, const CredentialStorage &cstore) :
_passphrase(passphrase), _cstore(cstore)
{
}

//! encrypt volume key (data) using encryption mech. defined by cipher
void RSACredentials::encryptVolumeKey(const CipherKey& key, 
                      const shared_ptr<Cipher> &keyCipher,
                      vector<unsigned char> &data) {
    
    int bufLen = keyCipher->encodedKeySize();
    unsigned char *tmpBuf = new unsigned char [bufLen], *cipher = NULL;
    keyCipher->writeRawKey(key, tmpBuf);
    struct rsautl_args rsaargs;
    char *pubkeyfilename = strdup(_cstore->getCredData(RSACredentialStorage::RSA_PUBKEYFILE_KEY).c_str());
    
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
    
    if (rsaargs.outsize > 0) { // something got written
        data.resize(rsaargs.outsize);
        data.assign(rsaargs.outbuf, rsaargs.outbuf + rsaargs.outsize);
        free(rsaargs.outbuf);
        if (pubkeyfilename) free(pubkeyfilename);
    } else {
        data.clear();
        std::cerr << "Shit's all fucked up, yo" << std::endl;
    }
    
}


//! decrypt a volume key (data) of type (cipher)
CipherKey RSACredentials::decryptVolumeKey(const vector<unsigned char> &data,
                                           const shared_ptr<Cipher> &kc)
{
    // XXX <- Not a good idea to guess 'data's size this way
    int bufLen = MAX_RSA_CIPHERTEXT_LENGTH;
    
    struct rsautl_args rsaargs;
    char *privkeyfilename = strdup(_cstore->getCredData(RSACredentialStorage::RSA_PRIVKEYFILE_KEY).c_str());
    string passwordarg("pass:");
    passwordarg += _passphrase;
    char *pwarg = strdup(passwordarg.c_str());
    
    rsaargs.inbuf = const_cast<unsigned char*>(&data[0]);
    rsaargs.insize = data.size(); // XXX FIXME
    rsaargs.outsize = 0;

    char *rsautl_decrypt_argv[] = {"rsautl",
        "-decrypt",
        "-passin", pwarg,
        "-inkey", privkeyfilename,
        "-inbuf"
        // "-in", "cipher.txt", "-out", "plain2.txt",
        };
    
    rsautl(7, rsautl_decrypt_argv, &rsaargs);
    
    CipherKey ret = kc->readRawKey(rsaargs.outbuf, true);
    
    if (rsaargs.outbuf) free (rsaargs.outbuf);
    if (pwarg) free(pwarg);
    if (privkeyfilename) free(privkeyfilename);
    
    return ret;
}

const string RSACredentialStorage::RSA_PRIVKEYFILE_KEY = "__yc_rsaprivkeyfile";
const string RSACredentialStorage::RSA_PUBKEYFILE_KEY = "__yc_rsapubkeyfile";

RSACredentialStorage::RSACredentialStorage(string privkeyfile, string pubkeyfile,
                                           const map<string, string> &otherparams)
{
//    _creds = otherparams;
    _creds[RSA_PRIVKEYFILE_KEY] = privkeyfile;
    _creds[RSA_PUBKEYFILE_KEY] = pubkeyfile;
    
    // Test to see if keys exist at given location. Else create them
    if (fs::exists(privkeyfile))
        _status = PrivKeyFound;
    else
        _status = PrivKeyNotFound;
}

bool
RSACredentialStorage::checkCredentials(string passphrase)
{
    if (fs::exists(_creds[RSA_PRIVKEYFILE_KEY])) {
        bool ret = true;
        char *pp = NULL;
        char *privkeyfile = strdup(_creds[RSA_PRIVKEYFILE_KEY].c_str());
        char *pubkeyfile = strdup(_creds[RSA_PUBKEYFILE_KEY].c_str());
        
        passphrase = string("pass:") + passphrase;
        pp = strdup(passphrase.c_str());
        
        // Check privkey
        char *rsa_checkprivkey_argv[] = {"rsa",
            "-inform", "PEM",
            "-in", privkeyfile,
#if defined(unix) || defined(__unix__) || defined(__unix) || (defined(__APPLE__) && defined(__MACH__))
            "-out", "/dev/null", // Dont print unencrypted RSA key to stdout
#endif
            "-ycpass", pp,
            "-check"
        };
        
        
        if (rsa(sizeof(rsa_checkprivkey_argv)/sizeof(rsa_checkprivkey_argv[0]),
                rsa_checkprivkey_argv)) {
            _status = PrivKeyReadError;
            ret = false;
            goto freestuff;
        }
        
        if (!fs::exists(pubkeyfile)) { // In case the pubkey doesn't exist
            char *genpubkey_argv[] = {"rsa",
                "-pubout",
                "-in", privkeyfile,
                "-out", pubkeyfile,
                "-ycpass", pp
            };
            
            if (rsa(sizeof(genpubkey_argv)/sizeof(genpubkey_argv[0]),
                    genpubkey_argv)) {
                std::cerr << "RSA pub key generation failed" << std::endl;
                _status = PubKeyCreateError;
                ret = false;
                goto freestuff;
            }
        }
        
        _status = KeyReadSuccess;
        
    freestuff:
        if(pp) free(pp);
        if(privkeyfile) free(privkeyfile);
        if(pubkeyfile) free(pubkeyfile);
        return ret;
    } else {
        return createKeys(passphrase);
    }
    
}

bool
RSACredentialStorage::createKeys(string passphrase)
{
    char *pp = NULL;
    char *privkeyfile = strdup(_creds[RSA_PRIVKEYFILE_KEY].c_str());
    char *pubkeyfile = strdup(_creds[RSA_PUBKEYFILE_KEY].c_str());
    bool ret = true;
    
    passphrase = "pass:" + passphrase;
    pp = strdup(passphrase.c_str());
    
    // Set mode of private key to 600
    fs::perms prms = fs::owner_read | fs::owner_write;
    fs::path privkeypath(_creds[RSA_PRIVKEYFILE_KEY]);
    
    char *genprivkey_argv[] = {"genpkey",
        "-out", privkeyfile,
        "-outform", "PEM",
        "-pass", pp,
        "-aes-256-cbc",
        "-algorithm", "RSA",
        "-pkeyopt", "rsa_keygen_bits:2048"
    };
    
    char *genpubkey_argv[] = {"rsa",
        "-pubout",
        "-in", privkeyfile,
        "-out", pubkeyfile,
        "-ycpass", pp
    };
    
    
    if (genpkey(sizeof(genprivkey_argv)/sizeof(genprivkey_argv[0]),
                genprivkey_argv)) {
        std::cerr << "RSA private key generation failed" << std::endl;
        _status = PrivKeyCreateError;
        ret = false;
        goto freestuff;
    }
    
    fs::permissions(privkeypath, prms);
    
    if (rsa(sizeof(genpubkey_argv)/sizeof(genpubkey_argv[0]),
            genpubkey_argv)) {
        std::cerr << "RSA pub key generation failed" << std::endl;
        _status = PubKeyCreateError;
        ret = false;
        goto freestuff;
    }
    
    _status = KeyCreateSuccess;
    
freestuff:
    if(pp) free(pp);
    if(privkeyfile) free(privkeyfile);
    if(pubkeyfile) free(pubkeyfile);
    
    return ret;
}

string
RSACredentialStorage::getCredData(const string credname)
{
    map<string, string>::const_iterator map_it;
    map_it = _creds.find(credname);
    if (map_it == _creds.end())
        return string();
    else
        return map_it->second;
}
