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

namespace youcrypt {
    

    class YoucryptFolder {
    public:

        //! Create a new object representing encrypted content at path.
        YoucryptFolder(const path&);

        //! Create a new config. at path and loads it up.
        bool createAtPath(const path&);

        //! Load config at path.
        bool loadConfigAtPath(const path&);
        
        //! Import content at the path specified into the folder.
        bool importContent(const path&);

        //! Import content at the path specified into the folder.
        bool importContent(const path&, const path&);

        //! Same as import, except not!
        bool exportContent(const path&, const path&);

        //! Helper opts initialization function.
    public:
        enum Status {
            //! Status is not known (not parseable, not readable, etc.)
            status_unknown, 
            //! Directory exists but is not a Youcrypt folder. (no
            //! config files, etc.)
            uninitialized,
            //! Directory contains a (partially) corrupt config.
            config_error,
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
