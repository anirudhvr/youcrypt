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

namespace youcrypt {

    struct YoucryptFolderOpts {
        //! Encrypt filenames: values from the anon. enum. below
        int filenameEncryption;

        //! List of filepatterns to not encrypt.
        vector<string> ignoreList;

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
        YoucryptFolderOpts() {

            filenameEncryption = filenamePlain;
            ignoreList.push_back(".DS_STORE");

            keySize = 256;
            blockSize = 1024;
            algoName = "aes";
            blockMACBytes = 8;
            blockMACRandBytes = 0;
            uniqueIV = true;
            chainedIV = true;
            externalIV = false;
        }            
    };

    class YoucryptFolder {
    public:
        //! Create a new object representing encrypted content at path.
        YoucryptFolder(const path&, 
                       const YoucryptFolderOpts &, 
                       const Credentials&);
        
        //! Simple constructor; does not read config.
        YoucryptFolder(const path&);
        
        
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
        const char *statusAsString()  { return statusString[status]; }
    public:
        enum Status {
            //! Status is not known (not parseable, not readable, etc.)
            statusUnknown = 0,
            //! Directory exists but is not a Youcrypt folder. (no
            //! config files, etc.)
            uninitialized,
            //! Directory contains a (partially) corrupt config.
            configError,
            //! Directory is a proper Youcrypt folder.
            initialized,
            //! Directory is being processed.  (files are being added
            //! / deleted, key is being changed, etc.)
            processing,            
            //! Directory is initialized at mounted.
            mounted
        };
        
        //! The status, except in words
        // Defined in YoucryptFolder.cpp
        static const char *statusString[];

    private:
        EncFS_Context ctx;
        boost::shared_ptr<Cipher> cipher;
        CipherKey volumeKey;
        boost::shared_ptr<DirNode> rootNode;
        shared_ptr<EncFSConfig> config;

        path mountPoint;
        path rootPath;
        vector<string> mountOptions;
        Status status;

        //! FIXME:  Not yet implemented.  Need to do this.
        bool idleTracking;        
    };
}

#endif
