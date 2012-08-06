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
#include <boost/algorithm/string.hpp>

using boost::filesystem::path;
using boost::filesystem::directory_iterator;
using boost::filesystem::ifstream;
using boost::filesystem::ofstream;

using boost::split;
using boost::is_any_of;

using youcrypt::YoucryptFolder;
using rel::Interface;

using rlog::RLogChannel;
using rlog::Log_Info;

static RLogChannel * Info = DEF_CHANNEL( "info/youcrypt", Log_Info );


static bool encryptData(shared_ptr<FileNode> file,
                        ifstream &input) {
    unsigned char buf[1024];
    off_t offset = 0;
    while (!input.eof()) {
        input.read((char *)buf, sizeof(buf));
        file->write(offset, (unsigned char *)buf, input.gcount());
        offset += input.gcount();
    }
    return true;
}

static bool decryptData(shared_ptr<FileNode> node,
                        ofstream &output) {
    off_t offset = 0;
    unsigned char buf[1024];
    int blocks = (node->getSize() + sizeof(buf)-1) / sizeof(buf);

    for(int i=0; i<blocks; ++i) {
        int bytes = node->read(offset, buf, sizeof(buf));
        output.write((char *)buf, bytes);
        offset += bytes;
    }    
    output.close();
    return true;
}

static void slashTerminate(string &str) 
{
    if (str[str.length() - 1] != '/')
        str.append(1, '/');
}


//! Helper function to import content in from a directory.
//! root is the root (DirNode) pointer of the volume.
//! sourcePath is where to import from
//! destSuffix is the suffix to the volume to import at.
//!    eg.  /blah == ENCFSROOT/blah
//! The function recurses if sourcePath is a directory.
//! FIXME:  Handle symlinks and non-regular files (sock, pipe, etc)
static bool encryptFolder(shared_ptr<DirNode> root,
                              const path &sourcePath,
                              string destSuffix) {
    rLog(Info, "importing content %s -> %s", 
         sourcePath.string().c_str(),
         destSuffix.c_str());
    struct stat st;
    if (stat (sourcePath.string().c_str(), &st))
        return false;
    if ((st.st_mode & S_IFREG) == S_IFREG) {
        shared_ptr<FileNode> fnode = root->lookupNode (
            destSuffix.c_str(),
            "yc-import");
        fnode->mknod(st.st_mode | S_IWUSR, 0, 0, 0);
        fnode->open(O_WRONLY);
        ifstream file(sourcePath);
        if (!encryptData(fnode, file))
            return false;
    } else if ((st.st_mode & S_IFDIR)) {
        root->mkdir(destSuffix.c_str(), st.st_mode, 0, 0);
        slashTerminate(destSuffix);
        for (directory_iterator curr = directory_iterator(sourcePath); 
             curr != directory_iterator(); ++curr) {
            if (!encryptFolder(root,
                               curr->path(),
                               destSuffix + curr->path().filename().string()))
                return false;
        }
    } // Handle symlinks here.
    return true;
}


//! Similar to above; except for exporting content.  Copies
//! <volSuffix>/ to <destPath>.  volSuffix should be a relative path in
//! the encrypted folder.  (eg. /blah is ENCFSROOT/blah)
//! FIXME: Symlinks are ignored.
static bool decryptFolder( shared_ptr<DirNode> root,
                           const path &destPath,
                           string volSuffix) {

    // Lookup directory node so we can create a destination directory
    // with the same permissions
    rLog(Info, "exporting content: %s -> %s", volSuffix.c_str(), 
          destPath.string().c_str());
    struct stat st;
    shared_ptr<FileNode> node = 
        root->lookupNode( volSuffix.c_str(), "yc-export" );
    if(node->getAttr(&st))
        return false;
    if ((st.st_mode & S_IFREG) == S_IFREG) {
        // Node's a regular file.
        // Just copy the content.
        int fd;
        if ((fd = open(destPath.c_str(),
                 O_CREAT | O_TRUNC | O_WRONLY,
                       st.st_mode | S_IWUSR)) < 0)
            return false;
        close(fd);
        node->open(O_RDONLY);

        ofstream dest(destPath);
        if (!decryptData(node, dest))
            return false;
    } else if ((st.st_mode & S_IFDIR)) {
        // Node's a directory.
        // Read and recurse
        slashTerminate(volSuffix);
        mkdir(destPath.string().c_str(), st.st_mode);
        DirTraverse dt = root->openDir(volSuffix.c_str());
        if(dt.valid())
        {
            for(string name = dt.nextPlaintextName(); !name.empty(); 
                name = dt.nextPlaintextName())
            {
                // Recurse to subdirectories
                if(name == "." || name == "..")
                    continue;
                if (!decryptFolder(
                        root, destPath / path(name), volSuffix + name))
                    return false;
            }
        }
    }
    return true;
}



// Function declared in FileUtils to find ciphers.
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
    config->kdfIterations = 16; // filled in by keying function
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

/*! (/full/path/to/<blah> goes to /<blah> in the folder).
 */
bool YoucryptFolder::importContent(const path& p) {
    return importContent (p, "/" + p.filename().string());
}

/*! Import path into relative path specified by the second argument.
 */
bool YoucryptFolder::importContent(const path& sourcePath, 
                                   string destSuffix) {

    if (destSuffix[0] != '/')
        destSuffix.insert(0, 1, '/');
    return encryptFolder(rootNode, sourcePath, destSuffix);
}

/*! Same as import, except not!
 */
bool YoucryptFolder::exportContent(const path& toPath, string volPath) {
    if (volPath[0] != '/')
        volPath.insert(0, 1, '/');
    return decryptFolder(rootNode, toPath, volPath);
}

// /*! Import to the root of the volume
//  */
// bool YoucryptFolder::exportContent(const path& toPath) {
//     return exportContent(toPath, "/" + toPath.filename().string());
// }


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


