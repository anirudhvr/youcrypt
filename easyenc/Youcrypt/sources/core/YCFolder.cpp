//
//  YCFolder.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/29/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "YCFolder.h"
#include "CredentialsManager.h"
#include <boost/filesystem/path.hpp>

using namespace youcrypt;

shared_ptr<YCFolder> 
YCFolder::initEncryptedFolderInPlaceAddExtension
    (string path,
     YoucryptFolderOpts opts) {


    // 1. (setup parameters) 
    //   shared_ptr to store the folder we create
    shared_ptr<YCFolder> out; 
    //   get active credentials from the global cred. manager
    Credentials creds = getGlobalCM()->getActiveCreds();
    //   destination path is path + YC_EXTENSION
    string destPath = path + YC_EXTENSION;

    // 2. (sanity check)
    //   check that destPath does not exists
    if (exists(boost::filesystem::path(destPath)))
        return out;

    // 3. (create destination)
    //   set up boost path and create directory.
    boost::filesystem::path dest(destPath);
    boost::filesystem::create_directories(destPath);

    out.reset(new YCFolder(dest, opts, creds));
    if (out->currStatus() != YoucryptFolder::initialized) {
        out.reset();
        return out;
    }

    if (!out->importContent(boost::filesystem::path(path))) {
        // FIXME: Import failed.
        out.reset();
        return out;
    }

    // 4. (delete directories in the source)
    boost::filesystem::path p(path);
    using boost::filesystem::directory_iterator;
    for (directory_iterator pi = directory_iterator(p),
         en = directory_iterator(); pi!=en; ++pi) {
        boost::filesystem::remove_all(pi->path());
    }

    // 5. (move files from dest to source)
    for (directory_iterator pi = directory_iterator(dest),
         en = directory_iterator(); pi!=en; ++pi) {
        boost::filesystem::copy_file(pi->path(), p/(pi->path().filename()));
        boost::filesystem::remove_all(pi->path());
    }
    boost::filesystem::remove_all(dest);

    // 6. (sanity check)
    //   open the encrypted folder at source and verify status is
    //   OK on open.
    out.reset(new YCFolder(p, creds));
    if (out->currStatus() != YoucryptFolder::initialized) {
        out.reset();
        return out;
    }
    return out;
}

shared_ptr<YCFolder> YCFolder::importFolderAtPath(string) {
    return shared_ptr<YCFolder>();
}

YCFolder::YCFolder(const path &p,
                   const YoucryptFolderOpts &o,
                   const Credentials &c): YoucryptFolder(p,o,c) {
}

YCFolder::YCFolder(const path &p,
                   const Credentials &c):YoucryptFolder() {
    YoucryptFolder::loadConfigAtPath(p, c);
}
