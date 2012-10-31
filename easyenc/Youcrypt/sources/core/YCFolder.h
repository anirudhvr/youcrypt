//
//  YCFolder.h
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 8/29/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__YCFolder__
#define __Youcrypt__YCFolder__

#include <string>
#include <boost/shared_ptr.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include "encfs-core/YoucryptFolder.h"
#include "encfs-core/Credentials.h"
#include "encfs-core/PassphraseCredentials.h"
#include "encfs-core/RSACredentials.h"

using boost::shared_ptr;
using std::string;

namespace youcrypt {

    enum {
        //! Directory does not exist / unreadable
        YoucryptDirectoryStatusUnknown
        = YoucryptFolder::statusUnknown,
        //! Directory is uninitialized (exists, no config)
        YoucryptDirectoryStatusUninitialized
        = YoucryptFolder::uninitialized,
        //! Directory contains a config that is unreadable
        YoucryptDirectoryStatusBadConfig
        = YoucryptFolder::configError,
        //! Dir. has a config but can't be unlocked with 
        //! the creds
        YoucryptDirectoryStatusNeedAuth 
        = YoucryptFolder::credFail,
        //! Dir. has a config, that can be read and unlocked
        //! using creds from the global cred manager.
        YoucryptDirectoryStatusInitialized
        = YoucryptFolder::initialized,
        //! Is being processed
        YoucryptDirectoryStatusProcessing
        = YoucryptFolder::processing,
        //! Is mounted
        YoucryptDirectoryStatusMounted
        = YoucryptFolder::mounted,
        //! Unlocked, has a mount point set up
        YoucryptDirectoryStatusReadyToMount,
    };

//! Class YCFolder: should implement all use cases
//   of YoucryptFolder from our perspective.
class YCFolder : protected YoucryptFolder {
protected:
    //! Constructors are protected.  Use the static methods for constr.

    //! Constructor for creation from scratch
    YCFolder(const path& p, 
             const YoucryptFolderOpts & o, 
             const Credentials& c);

    //! Constructor for opening an existing folder
    YCFolder(const path& p,
             const Credentials &c);

    //! Constructor to scan an existing folder
    YCFolder(const path &);
protected:
    string _mountedPath;
    string _mountedDate;
    vector<string> _mountOpts;
    int _idleTO;
    string _alias;
    bool _isMounted;
public:
    // Properties (read-only)
    string mountedPath();
    string mountedDate();
    string rootPath();    


    // States
    int currStatus();
    string stringStatus();
    void updateStatus();
    bool isMounted();
    bool isCreatable();
    bool isUnlocked();

public:
    //! Read/write alias
    string &alias();

    //! Set up mount
    bool setMountLocation(string);
    void setMountOpts(const vector<string> &, int);
    //! Mount: status say it's mountable
    bool mount();
    //! Unmount: status should say it is mounted
    bool unmount();
    //! Clean up root path for a new filesystem
    bool cleanUpRoot();
    //! Add/delete a credential.
    bool addCredential(const Credentials &);
    bool deleteCredential(const Credentials &);
    bool restoreFolderInPlace();
    
    string uuid() { return YoucryptFolder::uuid(); }
    string ownerID() {return YoucryptFolder::ownerID(); }
    
public:
    static shared_ptr<YCFolder> 
        initEncryptedFolderInPlaceAddExtension(
            string,
            YoucryptFolderOpts=YoucryptFolderOpts());
    static shared_ptr<YCFolder>
        initFromScanningPath(string);

    template<class A>
        friend void boost::serialization::save(
            A &, 
            const shared_ptr<YCFolder> &,
            const unsigned int);
    template<class A>
        friend void boost::serialization::load(
            A &, 
            shared_ptr<YCFolder> &,
            const unsigned int);
    friend boost::serialization::access;
};

}

typedef shared_ptr<youcrypt::YCFolder> Folder;


using boost::serialization::make_nvp;
namespace boost {
    namespace serialization {
        template<class A>
        void save(A &ar, const Folder &f, const unsigned int) {
            string r = f->rootPath();
            ar & make_nvp("path", r);
            r = f->mountedPath();
            ar & make_nvp("mountedPath", r);
            r = f->mountedDate();
            ar & make_nvp("mountedDate", r);
            r = f->alias();
            ar & make_nvp("alias", r);
        }
        
        template<class A>
        void load(A &ar, Folder &f, const unsigned int) {
            string rp, mp, md, al;
            ar & make_nvp("path", rp);
            ar & make_nvp("mountedPath", mp);
            ar & make_nvp("mountedDate", md);
            ar & make_nvp("alias", al);
            f.reset(new youcrypt::YCFolder(boost::filesystem::path(rp)));            
        }

        template<class A>
        void serialize(A &ar, Folder &f, const unsigned int v) {
            split_free(ar, f, v);
        }
    }
}


#endif /* defined(__Youcrypt__YCFolder__) */
//
//  YoucryptDirectory.h
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//// C++ headers
//#include "DirectoryMap.h"
//
//@class PeriodicActionTimer;
//@class PassphraseManager;
//
//using namespace youcrypt;
//
//
//    boost::shared_ptr<YoucryptFolder> folder;
//}
//
//
//@property (nonatomic, strong) NSString *path;          // Path of the youcrypt directory.
//@property (nonatomic, strong) NSString *mountedPath;   // Path if the directory is mounted by us.
//@property (nonatomic, strong) NSString *alias;         // Readable name (last path component?)
//@property (nonatomic, strong) NSString *mountedDateAsString; // Time at which this folder was mounted
////@property (nonatomic, assign) NSUInteger status; // status description
//
//- (id) initWithPath:(NSString*)p;
//- (id) initWithArchive:(boost::archive::xml_iarchive &)ar;
//- (void) saveToArchive:(boost::archive::xml_oarchive &)ar;
//
///* C++ wrappers */
//- (BOOL) encryptFolderInPlaceWithPassphrase:(NSString*)pp
//                           encryptFilenames:(BOOL)encfnames;
//
//- (BOOL) decryptFolderInPlaceWithPassphrase:(NSString*)pp;
//
//- (BOOL) openEncryptedFolderAtMountPoint:(NSString*)destFolder
//                              withPassphrase:(NSString*)pp
//                                idleTime:(int)idletime
//                                fuseOpts:(NSDictionary*)fuseOpts;
//- (BOOL) closeEncryptedFolder;
//
//- (int) status;
//- (NSString*) getStatus;
//
//
//
//
///* Old methods */
////- (void) updateInfo;
////- (BOOL) checkYoucryptDirectoryStatus:(BOOL)forceRefresh;
////+ (void) refreshMountedFuseVolumes;
////+ (NSString*) statusToString:(NSUInteger)status;
////+ (BOOL) pathIsMounted:(NSString *)path;
//
//
//@end
//
//
//
