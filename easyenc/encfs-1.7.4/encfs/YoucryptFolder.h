/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_YoucryptFolder_incl_
#define _Youcrypt_YoucryptFolder_incl_

#include "Credentials.h"
#include <boost/filesystem.hpp>

using boost::filesystem::path;

namespace youcrypt {
    

    class YoucryptFolder {
    public:
        //! Create a new object representing encrypted content at path; use Credentials to decrypt volume key.
        YoucryptFolder(const path&, Credentials*);

        //! Import content at the path specified into the folder (<blah> goes to /<blah> in the folder).
        bool importContent(const path&);

        //! Import content at the path specified into the folder at the path specified.
        bool importContent(const path&, const path&);

        //! Same as import, except not!
        bool exportContent(const path&, const path&);
    public:
        enum Status {
            //! Status is not known (not parseable, not readable, etc.)
            status_unknown, 
            //! Directory exists but is not a Youcrypt folder. (no config files, etc.)
            uninitialized,
            //! Directory is a proper Youcrypt folder.
            initialized,
            //! Directory is being processed.  (files are being added / deleted, key is being changed, etc.)
            processing,            
            //! Directory is initialized at mounted.
            mounted
        };

    private:
        path rootPath;
        path mountPoint;
        string decryptedVolumeKey;
    };

}

#endif
