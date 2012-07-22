/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#include "YoucryptFolder.h"
#include "config.h"
#include "FSConfig.h"
#include "Cipher.h"
#include "NameIO.h"
#include "BlockNameIO.h"
#include "YCNameIO.h"
#include "DirNode.h"
#include "Interface.h"

#include "autosprintf.h"
#include "i18n.h"

#include <rlog/rlog.h>
#include <rlog/Error.h>

#include <iostream>
#include <boost/filesystem.hpp>

using std::cout;
using std::endl;
using boost::filesystem::path;

using youcrypt::YoucryptFolder;
using rel::Interface;



// Helper functions
Cipher::CipherAlgorithm findCipherAlgorithm(const char *name, int keySize );


/*! Implementation: Try to loadConfig and createAtPath otherwise.
 */
YoucryptFolder::YoucryptFolder(const path &_rootPath) {
    if (!loadConfigAtPath (_rootPath))
        createAtPath (_rootPath);
}

/*! Implementation: must be very simialr to createV6Config (except for
 *  Youcrypt specific customizations).
 */
bool YoucryptFolder::loadConfigAtPath(const path &_rootPath) {
    boost::shared_ptr<EncFSConfig> config(new EncFSConfig);
    status = YoucryptFolder::status_unknown;


    if(readConfig( _rootPath.string(), config ) == Config_None)
        return false;

    // The path already has a configuration.  and is loaded at
    // config.

    // Removed Option:  reverseEncryption

    // first, instanciate the cipher.
    cipher = config->getCipher();
    if(!cipher)
    {
        rError(_("Unable to find cipher %s, version %i:%i:%i"),
               config->cipherIface.name().c_str(),
               config->cipherIface.current(),
               config->cipherIface.revision(),
               config->cipherIface.age());
        // xgroup(diag)
        cout << _("The requested cipher interface is not available\n");
        return false;
    }

    // get user key
    CipherKey userKey;        

    // FIXME: Major fix me here.
    userKey = config->createUserKeyFromPassphrase("asdf");
    if(!userKey) 
        return false;

    for (int i=0; ((i<config->easyencNumUsers) && (!volumeKey)); ++i ) {
        volumeKey = cipher->readKey(config->getKeyData(), userKey, false);
    }

    // If !volumeKey, no volumeKey matched passphrase.
    if(!volumeKey)
        return false;

    userKey.reset();
    shared_ptr<NameIO> nameCoder = NameIO::New( config->nameIface, 
                                                cipher, volumeKey );
    if(!nameCoder)
    {
        rError(_("Unable to find nameio interface %s, version %i:%i:%i"),
               config->nameIface.name().c_str(),
               config->nameIface.current(),
               config->nameIface.revision(),
               config->nameIface.age());
        // xgroup(diag)
        cout << _("The requested filename coding interface is "
                  "not available\n");
        return false;
    }

    nameCoder->setChainedNameIV( config->chainedNameIV );
    nameCoder->setReverseEncryption( false );

    // FIXME:  This is painful.  DirNode stores this for no reason.
    // Why not config directly ?
    FSConfigPtr fsConfig( new FSConfig );
    fsConfig->cipher = cipher;
    fsConfig->key = volumeKey;
    fsConfig->nameCoding = nameCoder;
    fsConfig->config = config;

    // Removed Option: forceDecode
    fsConfig->forceDecode = false;
    fsConfig->reverseEncryption = false;
    fsConfig->opts.reset(); // This is never used (grep
    // checked). Set to null.

    rootNode = shared_ptr<DirNode>(new DirNode (&ctx, _rootPath.string(),
                                                fsConfig));
    status = YoucryptFolder::initialized;
    return true;
}

/*! Implementation: must be very similar to CreateV6Config (except for
 *  Youcrypt specific customizations).
 */
bool YoucryptFolder::createAtPath(const path& _rootPath) {

    status = YoucryptFolder::status_unknown;

    const std::string rootDir = _rootPath.string();

    // FIXME: This needs to happen.
    bool enableIdleTracking = false;
    bool forceDecode = false;
    bool reverseEncryption = false;

    RootPtr rootInfo;
    int numusers;

    // creating new volume key.. should check that is what the user is
    // expecting...
    // xgroup(setup)

    numusers = 1;

    int keySize = 0;
    int blockSize = 0;
    Cipher::CipherAlgorithm alg;
    Interface nameIOIface;
    int blockMACBytes = 0;
    int blockMACRandBytes = 0;
    bool uniqueIV = false;
    bool chainedIV = false;
    bool externalIV = false;
    bool allowHoles = true;
    long desiredKDFDuration = 3000; //FIXME: ParanoiaKDFDuration;

    if (reverseEncryption)
    {
        uniqueIV = false;
        chainedIV = false;
        externalIV = false;
        blockMACBytes = 0;
        blockMACRandBytes = 0;
    }

    if (reverseEncryption)
    {
        rError(_("Paranoia configuration not supported for --reverse"));
        return false;
    }

    // look for AES with 256 bit key..
    // Use block filename encryption mode.
    // Enable per-block HMAC headers at substantial performance penalty..
    // Enable per-file initialization vector headers.
    // Enable filename initialization vector chaning
    keySize = 256;
    blockSize = 1024; // FIXME: DefaultBlockSize;
    alg = findCipherAlgorithm("AES", keySize);

    // FIXME:  mangle Filenames
    bool mangleFilename = true;
    if (mangleFilename)
        nameIOIface = BlockNameIO::CurrentInterface();
    else
        nameIOIface = YCNameIO::CurrentInterface();

    blockMACBytes = 8;
    blockMACRandBytes = 0; // using uniqueIV, so this isn't necessary
    uniqueIV = true;
    chainedIV = true;
    externalIV = true;

    cipher = Cipher::New( alg.name, keySize );
    if(!cipher)
    {
        rError(_("Unable to instanciate cipher %s, key size %i, block size %i"),
                alg.name.c_str(), keySize, blockSize);
        return false;
    } else
    {
        rDebug("Using cipher %s, key size %i, block size %i",
                alg.name.c_str(), keySize, blockSize);
    }

    shared_ptr<EncFSConfig> config( new EncFSConfig );

    config->cfgType = Config_YC;
    config->cipherIface = cipher->interface();
    config->keySize = keySize;
    config->blockSize = blockSize;
    config->nameIface = nameIOIface;
    config->creator = "Youcrypt 0.9 ";
    config->subVersion = 0;
    config->blockMACBytes = blockMACBytes;
    config->blockMACRandBytes = blockMACRandBytes;
    config->uniqueIV = uniqueIV;
    config->chainedNameIV = chainedIV;
    config->externalIVChaining = externalIV;
    config->allowHoles = allowHoles;

    config->salt.clear();
    config->kdfIterations = 0; // filled in by keying function
    config->desiredKDFDuration = desiredKDFDuration;



    int encodedKeySize = cipher->encodedKeySize();
    unsigned char *encodedKey = new unsigned char[ encodedKeySize ];

    volumeKey = cipher->newRandomKey();

    /* easyenc - get first user key (existing code) */
    config->easyencNumUsers = numusers;
    config->easyencKeys.resize(numusers);

    // get user key and use it to encode volume key
    CipherKey userKey;

    userKey = config->createUserKeyFromPassphrase("asdf");

    cipher->writeKey( volumeKey, encodedKey, userKey );
    config->assignKeyData(encodedKey, encodedKeySize);
    
    /* easyenc set and encodedKeys */ 
    config->easyencKeys[0].assign(encodedKey, encodedKey+encodedKeySize);
    userKey.reset();
    delete[] encodedKey;

    /* easyenc - get user keys for remaining users */
    /* get rest of user keys */
    for (int i = 0; i < numusers; ++i) {
        CipherKey userKey_other;
        unsigned char *encodedKey_other = new unsigned char[ encodedKeySize ];
        userKey_other = config->createUserKeyFromPassphrase("asdf");

        cipher->writeKey(volumeKey, encodedKey_other, userKey_other);
        config->easyencKeys[i].assign(encodedKey_other,
                encodedKey_other + encodedKeySize);
        userKey_other.reset();
        delete [] encodedKey_other;
    }

    if(!volumeKey)
        return false;

    // Rajsekar Manokaran
    // Add default whitelist 
    config->ignoreList.push_back(".DS_STORE");
    config->ignoreList.push_back(".ignore_enc");

    if(!saveConfig( Config_YC, rootDir, config ))
        return false;

    // fill in config struct
    shared_ptr<NameIO> nameCoder = NameIO::New( config->nameIface,
            cipher, volumeKey );
    if(!nameCoder)
    {
        rWarning(_("Name coding interface not supported"));
        cout << _("The filename encoding interface requested is not available") 
            << endl;
        return false;
    }

    nameCoder->setChainedNameIV( config->chainedNameIV );
    nameCoder->setReverseEncryption( reverseEncryption );

    FSConfigPtr fsConfig (new FSConfig);
    fsConfig->cipher = cipher;
    fsConfig->key = volumeKey;
    fsConfig->nameCoding = nameCoder;
    fsConfig->config = config;
    fsConfig->forceDecode = forceDecode;
    fsConfig->reverseEncryption = reverseEncryption;
    fsConfig->idleTracking = enableIdleTracking;
    fsConfig->opts.reset();  // Again, grep showed that this is never used.

    rootNode = shared_ptr<DirNode>( 
            new DirNode( &ctx, rootDir, fsConfig ));
    return true;
}

/*! Import content at the path specified into the folder (<blah> goes
 *  to /<blah> in the folder).
 */
bool YoucryptFolder::importContent(const path&) {
    return true;
}

/*! Import content at the path specified into the folder at the path
 *  specified.
 */
bool YoucryptFolder::importContent(const path&, const path&) {
    return true;
}

/*! Same as import, except not!
 */
bool YoucryptFolder::exportContent(const path&, const path&) {
    return true;
}
