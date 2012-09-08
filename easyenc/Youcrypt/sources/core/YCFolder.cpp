//
//  YCFolder.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/29/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

// Design Details:

// * Static Constructor functions to create new folders
// ** Scenarios
// *** An yet unseen path comes into the system.
//  Handled by initFromScanningPath
// *** User asks to create an encrypted folder
//  Current YC implementation is to add an extension, and
//  move stuff around.
//  Handled by initEncryptedFolderInPlaceAddExtension
// *** 

#include "YCFolder.h"
#include "CredentialsManager.h"
#include <boost/filesystem/path.hpp>

using namespace youcrypt;

static const char*statusInString[] = {
    "Status unknown",
    "Config not found",
    "Config error",
    "Authentication failed",
    "Initialized",
    "Processing",
    "Mounted",
    "Ready to mount"
};

using boost::filesystem::path;
static void moveDirectory(path src, path dest) 
{
    // src and dest are presumed to exist.
    using namespace boost::filesystem;
    if (exists(src)) {
        for (directory_iterator si = directory_iterator(src),
                 se = directory_iterator();
             si != se;
             ++si) {
            if (is_regular_file(*si))
                copy_file(*si, 
                          dest / si->path().filename());
            else if (is_directory(*si)) {
                create_directories( dest / si->path().filename());
                moveDirectory(*si, dest / si->path().filename());
            }
        }
    }
}

shared_ptr<YCFolder> 
YCFolder::initEncryptedFolderInPlaceAddExtension
    (string path,
     YoucryptFolderOpts opts)
{


    // 1. (setup parameters) 
    //   shared_ptr to store the folder we create
    shared_ptr<YCFolder> out; 
    //   get active credentials from the global cred. manager
    vector<Credentials> credss = getGlobalCM()->getEncodingCreds();
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

    out.reset(new YCFolder(dest, opts, credss[0]));
    if (out->currStatus() != YoucryptFolder::initialized) {
        out.reset();
        return out;
    }

    if (!out->importContent(boost::filesystem::path(path), "/")) {
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
    moveDirectory(dest, p);
    boost::filesystem::remove_all(dest);

    // 6. (rename source to dest)
    boost::filesystem::rename(p, dest);


    // 7. (sanity check)
    //   open the encrypted folder at source and verify status is
    //   OK on open.
    out.reset(new YCFolder(dest, credss[0]));
    if (out->currStatus() != YoucryptFolder::initialized) {
        out.reset();
        return out;
    }
    for (int i=1; i<credss.size(); i++)
        out->addCredential(credss[i]);
    return out;
}

Folder YCFolder::initFromScanningPath(string p) {
    using boost::filesystem::path;
    path pt(p);
    Folder out;
    out.reset(new YCFolder(p));
    return out;
}

string YCFolder::mountedPath() {
    if (status == YoucryptDirectoryStatusReadyToMount
        || status == YoucryptDirectoryStatusMounted)
        return _mountedPath;
    else
        return "";
}

string YCFolder::mountedDate() 
{
    if (status == YoucryptDirectoryStatusReadyToMount
        || status == YoucryptDirectoryStatusMounted)
        return _mountedDate;
    else
        return "";
}

string YCFolder::rootPath() 
{
    return YoucryptFolder::rootPath.string();
}

int YCFolder::currStatus() 
{
    updateStatus();
    return status;
}

string YCFolder::stringStatus() 
{
    return statusInString[status];
}

void YCFolder::updateStatus() 
{
    string msg = YoucryptFolder::getFuseMessage();
    if (msg == "unmount") {
        _isMounted = false;
        status = YoucryptDirectoryStatusInitialized;
    }
}

bool YCFolder::isMounted() 
{
    return _isMounted;
}

bool YCFolder::isCreatable() 
{
    if (boost::filesystem::exists(YoucryptFolder::rootPath) &&
        boost::filesystem::is_directory(YoucryptFolder::rootPath))
        return true;
    else
        return false;
}

bool YCFolder::isUnlocked() 
{
    if (status == YoucryptDirectoryStatusUninitialized
        || status == YoucryptDirectoryStatusUnknown)
        return false;
    if (volumeKey)
        return true;
    Credentials cred = getGlobalCM()->getActiveCreds();
    YoucryptFolder::loadConfigAtPath(YoucryptFolder::rootPath, cred);
    if (volumeKey)
        return true;
    else
        return false;
}

string &YCFolder::alias() 
{
    return _alias;
}

bool YCFolder::setMountLocation(string mountPoint) 
{
    using boost::filesystem::path;
    using boost::filesystem::create_directories;
    using boost::filesystem::exists;

    if (status == YoucryptDirectoryStatusInitialized) {
        path p(mountPoint);
        if (exists(p))
            return false;
        create_directories(p);
        if (!is_directory(p))
            return false;
        _mountedPath = mountPoint;
        status = YoucryptDirectoryStatusReadyToMount;
        return true;
    } else 
        return false;
}

void YCFolder::setMountOpts(const vector<string> &opts, int idleTimeOut) 
{
    if (status == YoucryptDirectoryStatusReadyToMount) {
        _mountOpts = opts;
        _idleTO = idleTimeOut;
    }
}

bool YCFolder::mount() 
{
    if (status == YoucryptDirectoryStatusReadyToMount) {
        status = YoucryptDirectoryStatusInitialized;        
        if (YoucryptFolder::mount(boost::filesystem::path(
                                         _mountedPath),
                                  _mountOpts, _idleTO)) {
            _isMounted = true;
            return true;
        }
    }
    return false;
}

bool YCFolder::unmount() 
{
    if (YoucryptFolder::unmount()) {
        _isMounted = false;
    }    
}

bool YCFolder::cleanUpRoot() 
{
    if (isCreatable()) {
        //FIXME:  Delete everything here
    }
}

bool YCFolder::addCredential(const Credentials &cred) 
{
    return YoucryptFolder::addCredential(cred);
}

bool YCFolder::deleteCredential(const Credentials &cred) 
{
    return YoucryptFolder::deleteCredential(cred);
}

bool YCFolder::restoreFolderInPlace() 
{
    if (status != YoucryptDirectoryStatusInitialized)
        return false;
    int ostatus = status;
    status = YoucryptDirectoryStatusProcessing;

    path newPath(YoucryptFolder::rootPath);
    path encPath(newPath);

    newPath = newPath.parent_path() / newPath.stem();
    if (exists(newPath)) {
        newPath = newPath.parent_path() / path(
            string("decrypted data from ") 
            + newPath.filename().string());
    }
    int cnt = 1;
    string destStr = newPath.string();
    while (exists(newPath)) {
        cnt++;
        string sCnt;
        std::ostringstream(sCnt) << cnt;
        newPath = path(destStr + sCnt);
    }
    status = YoucryptDirectoryStatusInitialized;
    YoucryptFolder::exportContent(newPath, "/");

    // 4. (delete directories in the source)
    encPath = YoucryptFolder::rootPath;
    using boost::filesystem::directory_iterator;
    for (directory_iterator pi = directory_iterator(encPath),
             en = directory_iterator(); pi!=en; ++pi) {
        boost::filesystem::remove_all(pi->path());
    }

    // 5. (move files from dest to source)
    moveDirectory(newPath, encPath);
    boost::filesystem::remove_all(newPath);

    // 6. (rename source to dest)
    boost::filesystem::rename(encPath, newPath);


    status = ostatus;
    return true;
}


YCFolder::YCFolder(const path &p,
                   const YoucryptFolderOpts &o,
                   const Credentials &c): YoucryptFolder(p,o,c) {
    _alias = p.filename().stem().string();
}

YCFolder::YCFolder(const path &p,
                   const Credentials &c):YoucryptFolder() {
    YoucryptFolder::loadConfigAtPath(p, c);
    _alias = p.filename().stem().string();
}

YCFolder::YCFolder(const path &p): YoucryptFolder(p) 
{
    if (status == YoucryptDirectoryStatusNeedAuth) {
        if (getGlobalCM()) {
            Credentials cred;
            if ((cred = getGlobalCM()->getActiveCreds())) {
                loadConfigAtPath(p, cred);
            }
        }
    }
    _alias = p.filename().stem().string();
}

//BOOST_SERIALIZATION_SPLIT_FREE(Folder);