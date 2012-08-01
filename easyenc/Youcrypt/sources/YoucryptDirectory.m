//
//  YoucryptDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoucryptDirectory.h"
#import "libFunctions.h"
#import "PeriodicActionTimer.h"

@implementation YoucryptDirectory

@synthesize path;
@synthesize mountedPath;
@synthesize alias;
@synthesize mountedDateAsString;
@synthesize status;

static BOOL globalsAllocated = NO;
static NSMutableArray *mountedFuseVolumes;
//static int minRefreshTime = 5; // at most every 30 seconds


- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self != nil) {
        path = [decoder decodeObjectForKey:@"path"];
        mountedPath = [decoder decodeObjectForKey:@"mountedPath"];
        alias = [decoder decodeObjectForKey:@"alias"];
        mountedDateAsString = [decoder decodeObjectForKey:@"mountedDateAsString"];
        status = [decoder decodeIntegerForKey:@"status"];
//        if (status == YoucryptDirectoryStatusProcessing)
//            status = YoucryptDirectoryStatusNotFound;

        if (!alias)
            alias = [[NSString alloc] init];
        
        if ([alias isEqualToString:@""]) {
            alias = [path lastPathComponent];
        }
//        timer = [[PeriodicActionTimer alloc] initWithMinRefreshTime:minRefreshTime];
        @synchronized(self) {
            if (globalsAllocated == NO) {
                mountedFuseVolumes = [[NSMutableArray alloc] init];
                [YoucryptDirectory refreshMountedFuseVolumes];
                globalsAllocated = YES;
            } 
        }
    }
    return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:path forKey:@"path"];
    [encoder encodeObject:mountedPath forKey:@"mountedPath"];
    [encoder encodeObject:alias forKey:@"alias"];
    [encoder encodeObject:mountedDateAsString forKey:@"mountedDateAsString"];
    [encoder encodeInteger:status forKey:@"status"];
}

- (void) updateInfo
{
    [self checkYoucryptDirectoryStatus:NO];
}

- (BOOL)checkYoucryptDirectoryStatus:(BOOL)forceRefresh
{  
//    @synchronized(self) {
//        
//        if (forceRefresh || [timer timerElapsed]) {
//            [YoucryptDirectory refreshMountedFuseVolumes];
//        }
//        
//    }
    if (forceRefresh)
        [YoucryptDirectory refreshMountedFuseVolumes];
    
    NSUInteger indexOfPath = [mountedFuseVolumes indexOfObject:mountedPath];
    BOOL isDir = NO;
    BOOL sourcedirExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil];
    BOOL mountpathExists = [[NSFileManager defaultManager] fileExistsAtPath:mountedPath isDirectory:&isDir];
    
    if (status == YoucryptDirectoryStatusProcessing) // We don't handle this.
        return YES;    
    else if (!sourcedirExists) {
        status = YoucryptDirectoryStatusSourceNotFound;
        return YES;
    }
    else if (mountpathExists && indexOfPath != NSNotFound) {        
        status = YoucryptDirectoryStatusMounted;
        return YES;
    }
    else {
        status = YoucryptDirectoryStatusUnmounted;
        mountedPath = @"";
        return YES;
    }
    
//    
//    if (!sourcedirExists) {
//        status = YoucryptDirectoryStatusSourceNotFound;
//        return NO;
//    }
//    
//    if (status == YoucryptDirectoryStatusMounted) {         // Directory was mounted last we checked
//        if (indexOfPath == NSNotFound) {                    // Not mounted any more 
//            if (!mountpathExists) {                               // mount point has been removed
//                status = YoucryptDirectoryStatusNotFound;
//            } else {                                        // mount point exists, but is just not mounted
//                status = isDir ? YoucryptDirectoryStatusUnmounted : YoucryptDirectoryStatusSourceNotFound;
//                DDLogVerbose(@"Mounted %@ being set to %@", path, [YoucryptDirectory statusToString:status]);
//
//            }
//        }
//    } else if (status == YoucryptDirectoryStatusUnmounted) {// Directory was umounted/closed 
//        if (indexOfPath != NSNotFound) {                    // Surprise -- an umounted folder has been surprisingly mounted
//            status = YoucryptDirectoryStatusMounted;
//            DDLogVerbose(@"Unounted %@ being set to %@", path, [YoucryptDirectory statusToString:status]);
//        } else {                                            // Still not mounted
//            if (!mountpathExists)                                 // If dir is missing
//                status = YoucryptDirectoryStatusNotFound;    
//            else if (!isDir)                                // mountedPath is not a dir (!)
//                status = YoucryptDirectoryStatusSourceNotFound;
//            else                                            // Path still exists; no change in status
//                status = YoucryptDirectoryStatusUnmounted;
//        }
//    } else if (status != YoucryptDirectoryStatusProcessing) {
//        if (sourcedirExists)
//            status = YoucryptDirectoryStatusUnmounted;
//    }
    return YES;
}



// Refreshes the static variable mountedFuseVolumes at most every 5 minutes

+ (void) refreshMountedFuseVolumes 
{
    NSFileHandle *fh = [NSFileHandle alloc];
    NSTask *mountTask = [NSTask alloc];
    NSArray *argsArray = [NSArray arrayWithObjects:@"-t", @"osxfusefs", nil];
    NSString *mountOutput;
    NSMutableArray *tmpMountedFuseVolumes = [[NSMutableArray alloc] init];
    
    
    if ([libFunctions execWithSocket:MOUNT_CMD arguments:argsArray env:nil io:fh proc:mountTask]) {
        [mountTask waitUntilExit];
        if (![libFunctions fileHandleIsReadable:fh]) {
            mountedFuseVolumes = tmpMountedFuseVolumes;
            return;
        }

        NSData *bytes = [fh availableData];
        mountOutput = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
        
        [fh closeFile];
    } else {
        DDLogVerbose(@"Could not exec mount -t osxfusefs");
        return;
    }
        

    NSMutableArray *mountLines = [[NSMutableArray alloc] initWithArray:[mountOutput componentsSeparatedByString:@"\n"]];
    
    
    for (NSString *line in mountLines) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression         
                                      regularExpressionWithPattern:@"^YoucryptFS on (.*) \\(osxfusefs*"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        [regex enumerateMatchesInString:line options:0 range:NSMakeRange(0, [line length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            [tmpMountedFuseVolumes addObject:[line substringWithRange:[match rangeAtIndex:1]]];
        }];
     
    }
    [mountedFuseVolumes removeAllObjects]; // clear existing array
    mountedFuseVolumes = tmpMountedFuseVolumes;
    NSString *mnted;
    DDLogInfo(@"Mounted fuse volumes:\n");
    for (mnted in mountedFuseVolumes) {
        DDLogInfo(@"mounted : %@\n", mnted);
    }
}

+ (BOOL) pathIsMounted:(NSString *)path {
    [YoucryptDirectory refreshMountedFuseVolumes];    
    if ([mountedFuseVolumes indexOfObject:path] == NSNotFound)
        return NO;
    else {
        return YES;
    }
}

+ (NSString*) statusToString:(NSUInteger)status
{
    switch(status) {
        case YoucryptDirectoryStatusNotFound:
            return @"Directory not found";
            break;
        case YoucryptDirectoryStatusMounted:
            return @"Open";
            break;
        case YoucryptDirectoryStatusUnmounted:
            return @"Closed";
            break;
        case YoucryptDirectoryStatusProcessing:
            return @"Processing";
            break;
        case YoucryptDirectoryStatusSourceNotFound:
            return @"Source directory not found";
            break;
        default:
            return nil;
    }
}


@end

