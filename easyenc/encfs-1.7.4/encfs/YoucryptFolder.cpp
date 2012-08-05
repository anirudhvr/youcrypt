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
#include "NullNameIO.h"
#include "YCNameIO.h"
#include "DirNode.h"
#include "Interface.h"

#include "autosprintf.h"
#include "i18n.h"

#include <rlog/rlog.h>
#include <rlog/Error.h>

#include <iostream>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

using boost::filesystem::path;
using boost::filesystem::directory_iterator;
using boost::filesystem::ifstream;

using youcrypt::YoucryptFolder;
using rel::Interface;



static bool encryptFolder( shared_ptr<DirNode> root,
                           const path &sourcePath,
                           const string &destSuffix) {

    if (exists(sourcePath)) {
        // does p actually exist?
        if (is_regular_file(sourcePath)) 
        {
            //  p is a regular file?                 
            shared_ptr<FileNode> fnode = root->lookupNode (
                (destSuffix + sourcePath.filename().string()).c_str(),
                "create");

            // FIXME:  take care of permissions.                
            fnode->mknod (
                S_IFREG | S_IRUSR | S_IWUSR | S_IWOTH | S_IROTH, 
                0, 0, 0);
            fnode->open (O_WRONLY);

            // FIXME:  do file IO to copy file contents.
            ifstream file(sourcePath);
            char buffer[1024];
            off_t offset = 0;
            while (!file.eof()) {
                file.read (buffer, 1024);
                fnode->write(offset, (unsigned char *)buffer, file.gcount());
                offset += file.gcount();
            }                                
        }
        else if (is_directory(sourcePath))      // is p a directory?
        {
            // FIXME:  take care of permissions.
            root->mkdir( 
                (destSuffix + sourcePath.filename().string()).c_str(),
                0777, 0, 0);
                
            for (directory_iterator curr = directory_iterator(sourcePath); 
                 curr != directory_iterator(); ++curr) {
                if (!encryptFolder (root, 
                               destSuffix + sourcePath.filename().string() 
                               + string("/"),
                                    curr->path().string()))
                    return false;
            }
        }
        else if (is_symlink(sourcePath)) {
            ;
            // FIXME: take care of symlinks that point within the
            // tree being copied.
            // FIXME: create a symlink.
        }
        else {   
            ;
            // FIXME:  Take care of these non-reg, non-dir, non-links.
        }
    }
    else {
        return false;
    }
    return true;

}



// Helper functions
Cipher::CipherAlgorithm findCipherAlgorithm(const char *name, int keySize );


/*! Implementation: Try to loadConfig and createAtPath otherwise.
 */
YoucryptFolder::YoucryptFolder(const path &_rootPath, 
                               const YoucryptFolderOpts& _opts,
                               const Credentials& creds) {
    if (!loadConfigAtPath (_rootPath, creds))
        createAtPath (_rootPath, _opts, creds);
}

/*! Implementation: must be very simialr to createV6Config (except for
 *  Youcrypt specific customizations).
 *  Details of Youcrypt modification (from encfs/initFS()):
 *
 *  * reverseEncryption is not used.
 *  * cred is passed the cipher and the encrypted volumeKey, to decode
 *    the volume key.
 *  * forceDecode is always set.
 */
bool YoucryptFolder::loadConfigAtPath(const path &_rootPath,
                                      const Credentials& cred) {
 
    status = YoucryptFolder::statusUnknown;

    boost::shared_ptr<EncFSConfig> config(new EncFSConfig);
    mountPoint = _rootPath;
    const string rootDir = _rootPath.string();

    if(readConfig( rootDir, config ) != Config_None)
    {
        // Status can at most be configuration file error.
        status = YoucryptFolder::configError;

        // YC: We don't support reverseEncryption
        // if(opts->reverseEncryption)
        // {
        //     if (config->blockMACBytes != 0
        //             || config->blockMACRandBytes != 0
        //             || config->uniqueIV || config->externalIVChaining
        //             || config->chainedNameIV )
        //     {  
        //         cout << _("The configuration loaded is not
        //         compatible with --reverse\n");
        //         
        //         return rootInfo;
        //     }
        // }

        // first, instanciate the cipher.
        cipher = config->getCipher();
        if(!cipher)
            return false;

        // YC: We don't create a user key, instead use the credentials
        //  passed to us to decode the volume key.
        // get user key
        // CipherKey userKey;
        // userKey = config->createUserKeyFromPassphrase("asdf");

        // if (!opts->no_interactive_configuration)  {

        //     if(opts->passwordProgram.empty()) {
        //         rDebug( "useStdin: %i", opts->useStdin );
        //         userKey = config->getUserKey( opts->useStdin );
        //     } else {
        //         userKey = config->getUserKey(
        //         opts->passwordProgram, opts->rootDir );
        //     } 
        // } else {
        //     rAssert(opts->num_users == 0 && opts->passphrases.size() == 1);
        //     userKey = config->
        //     createUserKeyFromPassphrase(opts->passphrases[0]);
        // }

        // if(!userKey) {
        //     return false;
        // }

        volumeKey = cred->decryptVolumeKey(config->getKeyData(), cipher);

        if(!volumeKey)
        {
            /* easyenc mods; old code below */
            /* try other keys */
            int i;
            for (i = 1; i < config->easyencNumUsers; ++i)
            {
                volumeKey = cred->decryptVolumeKey(
                        const_cast<unsigned char *>
                        (&(config->easyencKeys[i].front())),
                        cipher);
                if (!volumeKey) {
                    continue;
                } else {
                    /* cout << "Match found in easyenc key %d" << i << endl; */
                    break;
                }
            }

            if (!volumeKey)
                return false;
        }



        shared_ptr<NameIO> nameCoder = NameIO::New( config->nameIface, 
                cipher, volumeKey );
        if(!nameCoder)
            return false;

        nameCoder->setChainedNameIV( config->chainedNameIV );
        nameCoder->setReverseEncryption( false );

        FSConfigPtr fsConfig( new FSConfig );
        fsConfig->cipher = cipher;
        fsConfig->key = volumeKey;
        fsConfig->nameCoding = nameCoder;
        fsConfig->config = config;
        fsConfig->forceDecode = true;
        fsConfig->reverseEncryption = false;
        fsConfig->opts.reset();

        rootNode = shared_ptr<DirNode>( new DirNode (0, rootDir, fsConfig));
        status = YoucryptFolder::initialized;
        return true;
    } else
        return false;
}

/*! Implementation: must be very similar to CreateV6Config (except for
 *  Youcrypt specific customizations).
 */
bool YoucryptFolder::createAtPath(const path& _rootPath, 
                                  const YoucryptFolderOpts &opts,
                                  const Credentials& cred) 
{
    status = YoucryptFolder::statusUnknown;
    
    mountPoint = _rootPath;
    const string rootDir = _rootPath.string();
    bool enableIdleTracking = opts.idleTracking;
    const bool forceDecode = true;
    const bool reverseEncryption = false;

    int keySize = opts.keySize;
    int blockSize = opts.blockSize;

    Cipher::CipherAlgorithm alg;
    Interface nameIOIface;

    int blockMACBytes = 0;
    int blockMACRandBytes = 0;
    bool uniqueIV = false;
    bool chainedIV = false;
    bool externalIV = false;
    bool allowHoles = true;

    long desiredKDFDuration;
    int numusers;


    alg = findCipherAlgorithm("AES", keySize);
    switch (opts.filenameEncryption) {
    case YoucryptFolderOpts::filenamePlain:
        nameIOIface = NullNameIO::CurrentInterface();
        break;
    case YoucryptFolderOpts::filenameYC:
        nameIOIface = YCNameIO::CurrentInterface();
        break;
    case YoucryptFolderOpts::filenameEncrypt:
        nameIOIface = BlockNameIO::CurrentInterface();
        break;
    }

    blockMACBytes = opts.blockMACBytes;
    blockMACRandBytes = opts.blockMACRandBytes;
    uniqueIV = opts.uniqueIV;
    chainedIV = opts.chainedIV;
    externalIV = (uniqueIV && chainedIV && opts.externalIV);

    desiredKDFDuration = 3000; // ParanoidKDF in FileUtils.cpp
    allowHoles = true;
    numusers = 1; // Since we just took one cred.
    // END OF CONFIGURATIONS

    cipher = Cipher::New( alg.name, keySize );
    if(!cipher)
    {
        return false;
    }

    shared_ptr<EncFSConfig> config( new EncFSConfig );
    config->cfgType = Config_YC;
    config->cipherIface = cipher->interface();
    config->keySize = keySize;
    config->blockSize = blockSize;
    config->nameIface = nameIOIface;
    config->creator = "YoucryptFS " VERSION;
    config->subVersion = 0; // FIXME: YCSubVersion
    config->blockMACBytes = blockMACBytes;
    config->blockMACRandBytes = blockMACRandBytes;
    config->uniqueIV = uniqueIV;
    config->chainedNameIV = chainedIV;
    config->externalIVChaining = externalIV;
    config->allowHoles = allowHoles;

    config->salt.clear();
    config->kdfIterations = 0; // filled in by keying function
    config->desiredKDFDuration = desiredKDFDuration;

    // Create Volume Key

    int encodedKeySize = cipher->encodedKeySize();
    unsigned char *encodedKey = new unsigned char[ encodedKeySize ];
    volumeKey = cipher->newRandomKey();
    if(!volumeKey)
        return false;

    /* easyenc - get first user key (existing code) */
    config->easyencNumUsers = numusers;
    config->easyencKeys.resize(numusers);

    // get the volume key encrypted using cred.
    cred->encryptVolumeKey (volumeKey, cipher, encodedKey);

    // YC: This is really for backward compatibility with vanilla
    //   encfs.  When multiple creds exist, vanilla encfs can only
    //   mount with the first cred.  We can of course decode the vol.
    //   key using multiple creds.
    config->assignKeyData ( encodedKey, encodedKeySize );

    config->easyencKeys[0].assign(encodedKey, encodedKey+encodedKeySize);
    delete[] encodedKey;

    // /* easyenc set and encodedKeys */ 
    // config->easyencKeys[0].assign(encodedKey, encodedKey+encodedKeySize);
    // userKey.reset();
    // delete[] encodedKey;

    // /* easyenc - get user keys for remaining users */
    // /* get rest of user keys */
    // for (int i = 0; i < numusers; ++i) {
    //     CipherKey userKey_other;
    //     unsigned char *encodedKey_other = new unsigned char[ encodedKeySize ];
    //     userKey_other = config->createUserKeyFromPassphrase("asdf");

    //     cipher->writeKey(volumeKey, encodedKey_other, userKey_other);
    //     config->easyencKeys[i].assign(encodedKey_other,
    //             encodedKey_other + encodedKeySize);
    //     userKey_other.reset();
    //     delete [] encodedKey_other;
    // }


    config->ignoreList = opts.ignoreList;

    if(!saveConfig( Config_YC, rootDir, config ))
        return false;

    // fill in config struct
    shared_ptr<NameIO> nameCoder = NameIO::New( config->nameIface,
                                                cipher, 
                                                volumeKey );
    if(!nameCoder)
        return false;

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
    fsConfig->opts.reset();     // FIXME

    rootNode = shared_ptr<DirNode>(new DirNode (&ctx, rootDir, fsConfig));
    ctx.publicFilesystem = false;
    ctx.setRoot (rootNode);
    ctx.opts.reset();

    // TODO: Need to set some context stuff
    
    status = YoucryptFolder::initialized;
    return true;
}

/*! (<blah> goes to /<blah> in the folder).
 */
bool YoucryptFolder::importContent(const path& p) {
    return importContent (p, "/");
}

/*! Import path into relative path specified by the second argument.
 */
bool YoucryptFolder::importContent(const path& sourcePath, 
                                   const string& destSuffix) {
    for (directory_iterator curr = directory_iterator(sourcePath);
         curr != directory_iterator(); ++curr) {
        encryptFolder(rootNode, *curr, destSuffix);
    }
    return true;
}

/*! Same as import, except not!
 */
bool YoucryptFolder::exportContent(const path&, const path&) {
    return true;
}

bool YoucryptFolder::addCredential(const Credentials& newCred) {

    if ((status != YoucryptFolder::initialized) ||
        (status != YoucryptFolder::mounted)) {

        // Let other threads know that we're processing the config.
        YoucryptFolder::Status ostatus = status;
        status = YoucryptFolder::processing;
        boost::shared_ptr<EncFSConfig> config(new EncFSConfig);
        if (readConfig ( mountPoint.string(), config ) == Config_YC) {
            // volumeKey and cipher should already be initialized.

            int encodedKeySize = cipher->encodedKeySize();
            unsigned char *encodedKey = new unsigned char[ encodedKeySize ];

            newCred->encryptVolumeKey (volumeKey, cipher, encodedKey);
            config->easyencNumUsers++;
            config->easyencKeys.resize(config->easyencNumUsers);
            config->easyencKeys[config->easyencNumUsers - 1].
                assign(encodedKey, encodedKey+encodedKeySize);

            status = ostatus;
            return saveConfig(Config_YC, mountPoint.string(), config);
        } else {
            // Seems to be a config. error.  
            // Update the status
            status = YoucryptFolder::configError;
            return false;
        }
    } else 
        return false;
}


