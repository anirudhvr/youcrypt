//
//  YoucryptDirectory.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PeriodicActionTimer;
enum {
    YoucryptDirectoryStatusNotFound = 0,
    YoucryptDirectoryStatusMounted = 1,
    YoucryptDirectoryStatusUnmounted = 2,
    YoucryptDirectoryStatusSourceNotFound = 3,
    YoucryptDirectoryStatusProcessing = 4,
} YoucryptDirectoryStatus;

@interface YoucryptDirectory : NSObject <NSCoding> {
    PeriodicActionTimer *timer;
}

@property (nonatomic, strong) NSString *path;          // Path of the youcrypt directory.
@property (nonatomic, strong) NSString *mountedPath;   // Path if the directory is mounted by us.
@property (nonatomic, strong) NSString *alias;         // Readable name (last path component?)
@property (nonatomic, strong) NSString *mountedDateAsString; // Time at which this folder was mounted
@property (nonatomic, assign) NSUInteger status; // status description


- (void) updateInfo;
- (BOOL) checkYoucryptDirectoryStatus;
+ (void) refreshMountedFuseVolumes;
+ (NSString*) statusToString:(NSUInteger)status;


// Add more if needed.

@end

