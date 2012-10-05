/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_YoucryptFolder_incl_
#define _Youcrypt_YoucryptFolder_incl_

#include "Credentials.h"
#include "FileUtils.h"
#include "Context.h"
#include <boost/filesystem.hpp>

using boost::filesystem::path;
using std::string;
using std::vector;

struct fuse_conn_info;
extern "C" void youcrypt_mount_destroy(void *);
extern "C" void *youcrypt_mount_init(fuse_conn_info *conn);


namespace youcrypt {

    struct YoucryptFolderOpts {
        //! Encrypt filenames: values from the anon. enum. below
        int filenameEncryption;

        //! List of filepatterns to not encrypt.
        shared_ptr<vector<string> > ignoreList;

        //! Volume Key size
        int keySize;

        //! Block size if block encryption is intended.
        int blockSize;

        //! Algoname: aes, blowfish
        string algoName;
        
        int blockMACBytes;
        int blockMACRandBytes;
        bool uniqueIV;
        bool chainedIV;
        bool externalIV;        

        enum {
            filenamePlain,
            filenameYC,
            filenameEncrypt
        };
            

        //! Constructing providing sane defaults.
        YoucryptFolderOpts();
    };

    class YoucryptFolder {
    protected:
        YoucryptFolder(); //! For inherited classes
    public:
        //! Create a new object representing encrypted content at path.
        YoucryptFolder(const path&, 
                       const YoucryptFolderOpts &, 
                       const Credentials&);
        //! Simple constructor; does not read config.
        YoucryptFolder(const path&);
        
        virtual ~YoucryptFolder();

        //! Create a new config. at path and loads it up.
        bool createAtPath(const path&, 
                          const YoucryptFolderOpts &, 
                          const Credentials&);

        //! Load config at path.
        bool loadConfigAtPath(const path&, 
                              const Credentials&);
        
        //! Import content at the path specified into the folder.
        bool importContent(const path&);

        //! Import content at the path specified into the dest (suffix).
        bool importContent(const path&, string);

        //! Same as import, except not!
        bool exportContent(const path&, string);
        bool exportContent(const path&);

        bool mount(const path&, const vector<string> & = vector<string>(),
                   int=0);
        bool unmount(void);
        
        //! Add another cred. to an initialized folder
        bool addCredential(const Credentials&);
        /*! Delete the key correspondign to cred.  If multiple keys
         *  match delete teh first matching key.  Refuses to delete if
         *  the key is currently in use or if is the sole key.
         */
        bool deleteCredential(const Credentials&);

        int currStatus() { return status; }
        string getFuseMessage(bool=false);
        
    public:
        enum Status {
            //! Status is not known (not parseable, not readable, etc.)
            statusUnknown,
            //! Directory exists but is not a Youcrypt folder. (no
            //! config files, etc.)
            uninitialized,
            //! Directory contains a (partially) corrupt config.
            configError,
            //! Creds could not decrypt any volume key
            credFail,
            //! Directory is a proper Youcrypt folder.
            initialized,
            //! Directory is being processed.  (files are being added
            //! / deleted, key is being changed, etc.)
            processing,            
            //! Directory is initialized at mounted.
            mounted,
        };
        
    protected:
        EncFS_Context ctx;
        boost::shared_ptr<Cipher> cipher;
        CipherKey volumeKey;
        boost::shared_ptr<DirNode> rootNode;
        shared_ptr<EncFSConfig> config;

        path mountPoint;
        path rootPath;
        vector<string> mountOptions;
        int status;

        bool idleTracking;   
        int _fuseIn, _fuseOut;
        friend void *::youcrypt_mount_init(fuse_conn_info *conn);
        friend void ::youcrypt_mount_destroy(void *_ctx);

    };
}

#endif
