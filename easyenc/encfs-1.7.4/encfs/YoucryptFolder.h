/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_YoucryptFolder_incl_
#define _Youcrypt_YoucryptFolder_incl_

#include "Credentials.h"

using boost::filesystem::path;

namespace youcrypt {
    

    class YoucryptFolder {
    public:
        YoucryptFolder(const path&, Credentials*);

        void importContent(const path&);
        void importContent(const path&, const Path&);

        void exportDirectory(const path&, const path&);

    public:
        enum Status {
            status_unknown,
            uninitialized,
            initialized,
            processing,            
            mounted
        };

    private:
        path rootPath;
        string decryptedVolumeKey;
    };

}

#endif
