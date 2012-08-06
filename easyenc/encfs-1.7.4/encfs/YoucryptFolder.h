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
        //! Monitor filesystem idle time
        bool idleTracking;
        //! idle timeout (in seconds)
        unsigned int idleTrackingTimeOut;

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

            idleTracking = false;
            idleTrackingTimeOut = 0;

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

        //! Add another cred. to an initialized folder
        bool addCredential(const Credentials&);

        //! Helper opts initialization function.
    public:
        enum Status {
            //! Status is not known (not parseable, not readable, etc.)
            statusUnknown, 
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

    private:
        EncFS_Context ctx;
        boost::shared_ptr<Cipher> cipher;
        CipherKey volumeKey;
        boost::shared_ptr<DirNode> rootNode;

        path mountPoint;
        Status status;

        //! FIXME:  Not yet implemented.  Need to do this.
        bool idleTracking;        
    };

}

#endif
