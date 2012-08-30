//
//  YCFolder.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/29/12.
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

#define YC_EXTENSION ".yc"

namespace youcrypt {

//! Class YCFolder: should implement all use cases
//   of YoucryptFolder from our perspective.
class YCFolder : public YoucryptFolder {
protected:
    //! Constructors are protected.  Use the static methods for constr.

    //! Constructor for creation from scratch
    YCFolder(const path& p, 
             const YoucryptFolderOpts & o, 
             const Credentials& c);

    //! Constructor for opening an existing folder
    YCFolder(const path& p,
             const Credentials &c);
protected:
    string _mountedPath;
    string _mountedDate;
    string _alias;
public:
    // Properties (read-only)
    bool isMounted();
    string mountedPath();
    string mountedDate();
    string rootPath();    
    
public:
    // Operations
    string &alias();
    bool mount(string location);

public:
    static shared_ptr<YCFolder> 
        initEncryptedFolderInPlaceAddExtension(
            string,
            YoucryptFolderOpts=YoucryptFolderOpts());
    static shared_ptr<YCFolder>
        importFolderAtPath(string);
};

}


#endif /* defined(__Youcrypt__YCFolder__) */
//
//  YoucryptDirectory.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//// C++ headers
//#include "DirectoryMap.h"
//
//@class PeriodicActionTimer;
//@class PassphraseManager;
//@class YoucryptDirectory;
//
//using namespace youcrypt;
//
//
//@interface YoucryptDirectory : NSObject <NSCoding> {
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
