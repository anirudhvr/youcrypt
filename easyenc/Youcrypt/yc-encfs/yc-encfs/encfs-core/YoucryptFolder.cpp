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
#include "youcryptMountHelpers.h"

#include "autosprintf.h"
#include "i18n.h"
#include "openssl.h"

#include <rlog/rlog.h>
#include <rlog/Error.h>
#include <rlog/SyslogNode.h>
#include <rlog/RLogChannel.h>
#include <poll.h>


#include <iostream>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/scoped_ptr.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/foreach.hpp>
#include <boost/iostreams/device/file_descriptor.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/serialization/nvp.hpp>

using boost::iostreams::file_descriptor_source;
using boost::iostreams::stream;
using boost::archive::xml_iarchive;
using std::string;
using boost::serialization::make_nvp;
using boost::filesystem::path;
using boost::filesystem::directory_iterator;
using boost::filesystem::ifstream;
using boost::filesystem::ofstream;

using boost::tuple;
using boost::split;
using boost::is_any_of;
using boost::scoped_ptr;
using boost::shared_ptr;

using rel::Interface;
using rlog::RLogChannel;
using rlog::Log_Info;
using rlog::SyslogNode;

using namespace youcrypt;

static RLogChannel * Info = DEF_CHANNEL( "info/youcrypt", Log_Info );

// Function declared in FileUtils to find ciphers.
Cipher::CipherAlgorithm findCipherAlgorithm(const char *name, int keySize );

static
const char *
getConfigFileName(void)
{
    ConfigInfo *nm = ConfigFileMapping;
    while(!nm->fileName) {
        nm++;
    }
    return nm->fileName;
}

static bool encryptData(shared_ptr<FileNode> file,
                        ifstream &input) 
{
    unsigned char buf[1024];
    off_t offset = 0;
    while (!input.eof()) {
        input.read((char *)buf, sizeof(buf));
        if (input.gcount() > 0)
            file->write(offset, (unsigned char *)buf, input.gcount());
        offset += input.gcount();
    }
    return true;
}

static bool decryptData(shared_ptr<FileNode> node,
                        ofstream &output) 
{
    off_t offset = 0;
    unsigned char buf[1024];
    int blocks = (node->getSize() + sizeof(buf)-1) / sizeof(buf);

    for(int i=0; i<blocks; ++i) {
        int bytes = node->read(offset, buf, sizeof(buf));
        if (bytes > 0)
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
                           string volSuffix) 
{

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
                if(name == "." || name == ".." || name == getConfigFileName())
                    continue;
                if (!decryptFolder(
                        root, destPath / path(name), volSuffix + name))
                    return false;
            }
        }
    }
    return true;
}

/*! Implementation: Creates an empty object */
YoucryptFolder::YoucryptFolder()
{
    status = YoucryptFolder::statusUnknown;
}

/*! Implementation: Create a YoucryptFolder object
 */
YoucryptFolder::YoucryptFolder(const path &_rootPath) : YoucryptFolder()
{
    YoucryptFolder::YoucryptFolder();
    rootPath = _rootPath;
    string rootDir = _rootPath.string();
    slashTerminate(rootDir);
    loadConfigAtPath(_rootPath, Credentials());
}
                               
/*! Implementation: Try to loadConfig and createAtPath otherwise.
 */
YoucryptFolder::YoucryptFolder(const path &_rootPath,
                               const YoucryptFolderOpts& _opts,
                               const Credentials& creds) : YoucryptFolder(_rootPath)
{
    loadConfigAtPath(_rootPath, creds);
    if (status == YoucryptFolder::uninitialized)
        createAtPath(rootPath, _opts, creds);
}

YoucryptFolder::~YoucryptFolder() {
    if (status == YoucryptFolder::mounted)
        unmount();
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
                                      const Credentials& cred) 
{
 
    status = YoucryptFolder::statusUnknown;
    rootPath = _rootPath;
    string rootDir = _rootPath.string();
    slashTerminate(rootDir);

    if (exists(rootPath) && is_directory(rootPath))
        status = YoucryptFolder::uninitialized;
    else
        return false;

    config.reset(new EncFSConfig);

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

        if (cred) {
            for (int i=0; i<config->easyencNumUsers && !volumeKey; ++i)
                volumeKey = cred->decryptVolumeKey(config->easyencKeys[i], 
                                                   cipher);
        }

        if (!volumeKey) {
            status = YoucryptFolder::credFail;
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
        ctx.publicFilesystem = false;
        ctx.setRoot (rootNode);
        ctx.opts.reset();
        ctx.args.reset();


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
    
    rootPath = _rootPath;
    string rootDir = _rootPath.string();
    
    if (!exists(_rootPath))
        mkdir(rootDir.c_str(), 0755);
    
    slashTerminate(rootDir);
    bool enableIdleTracking = true;
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

    config.reset( new EncFSConfig );
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

    // This should really come from the cred. object.
    volumeKey = cipher->newRandomKey();
    if(!volumeKey)
        return false;

    /* easyenc - get first user key (existing code) */
    config->easyencNumUsers = numusers;
    config->easyencKeys.resize(numusers);

    // int encodedKeySize = cred->encodedKeySize(volumeKey, cipher);
    // boost::scoped_ptr<unsigned char> encodedKey (new unsigned char[ encodedKeySize ]);

    // get the volume key encrypted using cred.
    cred->encryptVolumeKey (volumeKey, cipher, config->easyencKeys[0]);
    int encodedKeySize = config->easyencKeys[0].size();
    // YC: This is really for backward compatibility with vanilla
    //   encfs.  When multiple creds exist, vanilla encfs can only
    //   mount with the first cred.  We can of course decode the vol.
    //   key using multiple creds.

    config->keyData.resize(encodedKeySize);
    std::copy(config->easyencKeys[0].begin(), config->easyencKeys[0].end(),
              config->keyData.begin());

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
    ctx.args.reset();
    // TODO: Need to set some context stuff
    
    status = YoucryptFolder::initialized;
    return true;
}

/*! (/full/path/to/<blah> goes to /<blah> in the folder).
 */
bool YoucryptFolder::importContent(const path& p) 
{
    return importContent (p, "/" + p.filename().string());
}

/*! Import path into relative path specified by the second argument.
 */
bool YoucryptFolder::importContent(const path& sourcePath, 
                                   string destSuffix) 
{
    if ((status != YoucryptFolder::initialized) &&
        (status != YoucryptFolder::mounted)) 
        return false;
    
    int ostatus = status;
    status = YoucryptFolder::processing;

    if (destSuffix[0] != '/')
        destSuffix.insert(0, 1, '/');

    bool ret = encryptFolder(rootNode, sourcePath, destSuffix);
    status = ostatus;
    return ret;
}

/*! Same as import, except not!
 */
bool YoucryptFolder::exportContent(const path& toPath, string volPath)
{

    if ((status != YoucryptFolder::initialized) &&
        (status != YoucryptFolder::mounted)) 
        return false;
    
    int ostatus = status;
    status = YoucryptFolder::processing;

    if (volPath[0] != '/')
        volPath.insert(0, 1, '/');

    bool ret = decryptFolder(rootNode, toPath, volPath);
    status = ostatus;
    return ret;
}

bool YoucryptFolder::exportContent(const path& toPath)
{
    return exportContent(toPath, "/");
}

bool YoucryptFolder::addCredential(const Credentials& newCred) 
{

    if ((status != YoucryptFolder::initialized) &&
        (status != YoucryptFolder::mounted))
        return false;

    // Let other threads know that we're processing the config.
    int ostatus = status;
    status = YoucryptFolder::processing;

    config.reset( new EncFSConfig );
    string rootDir = rootPath.string();
    slashTerminate(rootDir);
    if (readConfig ( rootDir, config ) == Config_YC) {
        // volumeKey and cipher should already be initialized.

        config->easyencKeys.push_back(vector<unsigned char>());
        config->easyencNumUsers++;
        newCred->encryptVolumeKey(volumeKey, cipher, 
                                  config->easyencKeys[config->easyencKeys.size()-1]);
        status = ostatus;
        return saveConfig(Config_YC, rootDir, config);
    } else {
        // Seems to be a config. error.  
        // Update the status
        status = YoucryptFolder::configError;
        return false;
    }
}

bool YoucryptFolder::deleteCredential(const Credentials& cred) 
{
    if ((status != YoucryptFolder::initialized) &&
        (status != YoucryptFolder::mounted))
        return false;

    // Let other threads know that we're processing the config.
    int ostatus = status;
    status = YoucryptFolder::processing;

    config.reset( new EncFSConfig );
    string rootDir = rootPath.string();
    slashTerminate(rootDir);
    if (readConfig( rootDir, config ) == Config_YC) {
        // volumeKey and cipher should already be initialized.

        int numUsers = config->easyencNumUsers;
        CipherKey decodedKey;
        if (numUsers == 1)
            return false;
        for (int i=0; i<numUsers; i++) {
            decodedKey = cred->decryptVolumeKey( config->easyencKeys[i], 
                                                 cipher);
            if (decodedKey && cipher->compareKey( decodedKey, volumeKey )) {
                // Found a match for the cred.
                config->easyencKeys.erase( config->easyencKeys.begin()+i );
                config->easyencNumUsers--;
            }
            status = ostatus;
            return saveConfig(Config_YC, rootDir, config);
        }
    }
    return false;
}



/*! Mount the decrypted folder at mountPoint.
 *  Implementation currently uses osx fuse.
 */
bool YoucryptFolder::mount(const path &_mountPoint, 
                           const vector<string> &_mountOptions,
                           int idleTimeout ) 
{
    if (status != YoucryptFolder::initialized)
        return false;
        
    mountPoint = _mountPoint;
    mountOptions = _mountOptions;
    ctx.mountPoint = mountPoint.string();
    ctx.idleTimeout = idleTimeout;    
    if (idleTimeout > 0)
        ctx.idleTracking = true;
    if (!(exists(mountPoint) && is_directory(mountPoint)))
        return false;

    int fromParent[2], toParent[2];
    pipe(fromParent);
    pipe(toParent);
    _fuseIn = toParent[0];
    _fuseOut = fromParent[1];

    pid_t newPid = fork();    
    if (newPid < 0)
        return false; // Error on fork.

    else if (newPid == 0) {
        // Child process
        // Close the out of fromParent
        close(fromParent[1]);
        // Close in of toParent
        close(toParent[0]);
        _fuseIn = fromParent[0];
        _fuseOut = toParent[1];

        // Code copied from main.cpp(encfs)

        // Set up the callbacks from fuse.
        fuse_operations mount_oper;
        memset(&mount_oper, 0, sizeof(fuse_operations));
        mount_oper.getattr = youcrypt_mount_getattr;
        mount_oper.readlink = youcrypt_mount_readlink;
        mount_oper.getdir = youcrypt_mount_getdir; // deprecated for readdir
        mount_oper.mknod = youcrypt_mount_mknod;
        mount_oper.mkdir = youcrypt_mount_mkdir;
        mount_oper.unlink = youcrypt_mount_unlink;
        mount_oper.rmdir = youcrypt_mount_rmdir;
        mount_oper.symlink = youcrypt_mount_symlink;
        mount_oper.rename = youcrypt_mount_rename;
        mount_oper.link = youcrypt_mount_link;
        mount_oper.chmod = youcrypt_mount_chmod;
        mount_oper.chown = youcrypt_mount_chown;
        mount_oper.truncate = youcrypt_mount_truncate;
        mount_oper.utime = youcrypt_mount_utime; // deprecated for utimens
        mount_oper.open = youcrypt_mount_open;
        mount_oper.read = youcrypt_mount_read;
        mount_oper.write = youcrypt_mount_write;
        mount_oper.statfs = youcrypt_mount_statfs;
        mount_oper.flush = youcrypt_mount_flush;
        mount_oper.release = youcrypt_mount_release;
        mount_oper.fsync = youcrypt_mount_fsync;
#ifdef HAVE_XATTR
        mount_oper.setxattr = youcrypt_mount_setxattr;
        mount_oper.getxattr = youcrypt_mount_getxattr;
        mount_oper.listxattr = youcrypt_mount_listxattr;
        mount_oper.removexattr = youcrypt_mount_removexattr;
#endif // HAVE_XATTR
        //mount_oper.opendir = youcrypt_mount_opendir;
        //mount_oper.readdir = youcrypt_mount_readdir;
        //mount_oper.releasedir = youcrypt_mount_releasedir;
        //mount_oper.fsyncdir = youcrypt_mount_fsyncdir;
        mount_oper.init = youcrypt_mount_init;
        mount_oper.destroy = youcrypt_mount_destroy;
        //mount_oper.access = youcrypt_mount_access;
        //mount_oper.create = youcrypt_mount_create;
        mount_oper.ftruncate = youcrypt_mount_ftruncate;
        mount_oper.fgetattr = youcrypt_mount_fgetattr;
        //mount_oper.lock = youcrypt_mount_lock;
        mount_oper.utimens = youcrypt_mount_utimens;
        //mount_oper.bmap = youcrypt_mount_bmap;
        
#if (__FreeBSD__ >= 10)
        // mount_oper.setvolname
        // mount_oper.exchange
        // mount_oper.getxtimes
        // mount_oper.setbkuptime
        // mount_oper.setchgtime
        // mount_oper.setcrtime
        // mount_oper.chflags
        // mount_oper.setattr_x
        // mount_oper.fsetattr_x
#endif

        // Settings used in code below.
        bool isThreaded = true;
        bool ownerCreate = false;
        bool isDaemon = true;

        openssl_init( isThreaded );
        ctx.publicFilesystem = ownerCreate;

        int returnCode = EXIT_FAILURE;
        ctx.setRoot(rootNode);
        ctx.args.reset();
        ctx.opts.reset();
        ctx.folder.reset(this);

        // Create fuse args
        mountOptions.push_back("-f");
        rAssert(mountOptions.size() <= 30);
        
        const char **fuseArgv = new char const *[32];
        int fuseArgc = 0;

        fuseArgv[fuseArgc++] = "YouCryptFS";
        fuseArgv[fuseArgc++] = mountPoint.string().c_str();

        BOOST_FOREACH( string arg, mountOptions ) {
            fuseArgv[fuseArgc++] = arg.c_str();
        }
                
        umask(0);            
        if(isDaemon)
        {
            using namespace rlog;
            // switch to logging just warning and error messages via syslog
            scoped_ptr<SyslogNode> logNode(new SyslogNode("youcrypt"));
            logNode->subscribeTo( GetGlobalChannel("warning") );
            logNode->subscribeTo( GetGlobalChannel("error") );
        }
            
        try
        {
            time_t startTime, endTime;
            // exit.  Only print information if fuse_main returned
            // immediately..
            time( &startTime );
            
                // fuse_main returns an error code in newer versions of fuse..
            int res = fuse_main( fuseArgc,
                                 const_cast<char**>(fuseArgv),
                                 &mount_oper, (void*)&ctx);
            time( &endTime );

            if(res == 0)
                returnCode = 0;

            if(res != 0 && isDaemon && (endTime - startTime <= 1) )
                returnCode = -1;

        } catch(std::exception &ex)
        {
            rError(_("Internal error: Caught exception from main loop: %s"), 
                   ex.what());
            returnCode = -1;
        } catch(...)
        {
            rError(_("Internal error: Caught unexpected exception"));
            returnCode = -1;
        }
        openssl_shutdown( isThreaded );
        exit(returnCode);
    }

    else if (newPid > 0) {

        // Parent process.
        close(fromParent[0]);
        close(toParent[1]);
        _fuseOut = fromParent[1];
        _fuseIn = toParent[0];

//        int stat;
//        do {
//            waitpid(newPid, &stat, 0);
//        } while (!(WIFEXITED(stat)));
        if (1) { //(WIFEXITED(stat) && !(WEXITSTATUS(stat))) {
//            status = YoucryptFolder::mounted;
//            return true;
            struct pollfd pf;
            pf.fd = _fuseIn;
            pf.events = POLLRDNORM;
            pf.revents = 0;
            
            // Wait for about 5 seconds to get a reply.
            ::poll(&pf, 1, 5000);
            if (!(pf.revents & POLLRDNORM)) {
                return false;
            }
            try {
            file_descriptor_source fdin(_fuseIn, boost::iostreams::never_close_handle);
            stream<file_descriptor_source> in(fdin);
            xml_iarchive xi(in);
            string msg;
            xi & make_nvp("Message", msg);
            if (msg == "initialized") {
                status = YoucryptFolder::mounted;
                return true;
            }
            else
                return false;
            } catch (...) {
                return false;
            }
        }
        else
            return false;
    }
}


// Fuse version >= 26 requires another argument to fuse_unmount, which we
// don't have.  So use the backward compatible call instead..
extern "C" void fuse_unmount_compat22(const char *mountpoint);
#    define fuse_unmount fuse_unmount_compat22

bool YoucryptFolder::unmount(void)
{
    if (status == YoucryptFolder::mounted) {
        fuse_unmount( mountPoint.c_str() );
        return true;
    } else {
        rWarning(_("Not umounnting since folder not mounted"),
                 mountPoint.c_str());
        // fuse_unmount( mountPoint.c_str() );
        return false;
    }
}



string YoucryptFolder::getFuseMessage(bool block) {
    if (status != YoucryptFolder::mounted)
        return "";
    struct pollfd pf;
    pf.fd = _fuseIn;
    pf.events = POLLRDNORM;
    pf.revents = 0;
    
    ::poll(&pf, 1, (block ? -1 : 0));
    if (!(pf.revents & POLLRDNORM)) {
        return "";
    }
    
    file_descriptor_source fdin(_fuseIn, boost::iostreams::never_close_handle);
    stream<file_descriptor_source> in(fdin);
    xml_iarchive xi(in);
    string msg;
    xi & make_nvp("Message", msg);
    return msg;
}

