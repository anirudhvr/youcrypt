//
//  YoucryptDirectory.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// C++ headers
#include <boost/shared_ptr.hpp>
#include "encfs-core/YoucryptFolder.h"
#include "encfs-core/Credentials.h"
#include "encfs-core/PassphraseCredentials.h"

@class PeriodicActionTimer;
enum {
    YoucryptDirectoryStatusNotFound = 0,
    YoucryptDirectoryStatusMounted = 1,
    YoucryptDirectoryStatusUnmounted = 2,
    YoucryptDirectoryStatusSourceNotFound = 3,
    YoucryptDirectoryStatusProcessing = 4,
} YoucryptDirectoryStatus;

@interface YoucryptDirectory : NSObject <NSCoding> {
    boost::shared_ptr<youcrypt::YoucryptFolder> folder;
}

@property (nonatomic, strong) NSString *path;          // Path of the youcrypt directory.
@property (nonatomic, strong) NSString *mountedPath;   // Path if the directory is mounted by us.
@property (nonatomic, strong) NSString *alias;         // Readable name (last path component?)
@property (nonatomic, strong) NSString *mountedDateAsString; // Time at which this folder was mounted
@property (nonatomic, assign) NSUInteger status; // status description


/* C++ wrappers */
- (BOOL) encryptFolderInPlaceWithPassphrase:(NSString*)pp
                           encryptFilenames:(BOOL)encfnames;

- (BOOL) decryptFolderInPlaceWithPassphrase:(NSString*)pp;

- (BOOL) openEncryptedFolderAtMountPoint:(NSString*)destFolder
                              withPassphrase:(NSString*)pp
                                idleTime:(int)idletime
                                fuseOpts:(NSDictionary*)fuseOpts;
- (BOOL) closeEncryptedFolder;


/* Old methods */
- (void) updateInfo;
- (BOOL) checkYoucryptDirectoryStatus:(BOOL)forceRefresh;
+ (void) refreshMountedFuseVolumes;
+ (NSString*) statusToString:(NSUInteger)status;
+ (BOOL) pathIsMounted:(NSString *)path;


@end

