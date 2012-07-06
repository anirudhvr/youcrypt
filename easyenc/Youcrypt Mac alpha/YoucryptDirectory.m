//
//  YoucryptDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoucryptDirectory.h"
#import "logging.h"
#import "libFunctions.h"

@implementation YoucryptDirectory

@synthesize path;
@synthesize mountedPath;
@synthesize alias;
@synthesize mountedDateAsString;
@synthesize status;

static BOOL globalsAllocated = NO;
static NSMutableArray *mountedFuseVolumes;
static NSDate *lastRefreshDate;
static int minRefreshTime = 5; // at most every 30 seconds


- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self != nil) {
        path = [decoder decodeObjectForKey:@"path"];
        mountedPath = [decoder decodeObjectForKey:@"mountedPath"];
        alias = [decoder decodeObjectForKey:@"alias"];
        mountedDateAsString = [decoder decodeObjectForKey:@"mountedDateAsString"];
        status = [decoder decodeIntegerForKey:@"status"];
        if (!alias)
            alias = [[NSString alloc] init];
        
        if ([alias isEqualToString:@""]) {
            alias = [path lastPathComponent];
        }
        @synchronized(self) {
            if (globalsAllocated == NO) {
                mountedFuseVolumes = [[NSMutableArray alloc] init];
                // Some date that is well before now
                lastRefreshDate = [NSDate dateWithString:@"2009-12-10 00:00:00 +0000"];
                globalsAllocated = YES;
            } 
            [YoucryptDirectory refreshMountedFuseVolumes];
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

- (void)checkIfStillMounted
{  
    @synchronized(self) {
        [YoucryptDirectory refreshMountedFuseVolumes];
    }
    
    NSUInteger indexOfPath = [mountedFuseVolumes indexOfObject:mountedPath];
    BOOL isDir = NO;
    BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:mountedPath isDirectory:&isDir];
    
    if (status == YoucryptDirectoryStatusMounted) {
        if (indexOfPath == NSNotFound) {
            if (!dirExists) {
                // mount point has been removed
                status = YoucryptDirectoryStatusNotFound;
            } else {
                // mount point exists, but is just not mounted
                status = isDir ? YoucryptDirectoryStatusUnmounted : YoucryptDirectoryStatusMounted;
            }
        }
    } else {
        if (indexOfPath != NSNotFound) {
            // Surprise -- an umounted folder has been surprisingly mounted
            status = YoucryptDirectoryStatusMounted;
        } else {
            if (!dirExists || !isDir) 
                status = YoucryptDirectoryStatusError;
            else
                status = YoucryptDirectoryStatusUnmounted;
        }
    }
}



// Refreshes the static variable mountedFuseVolumes at most every 5 minutes

+ (void) refreshMountedFuseVolumes 
{
    // Return if we have 
    //      NSLog(@"Time intervals: %f, %f", [[NSDate date] timeIntervalSince1970], [lastRefreshDate timeIntervalSince1970]);
    if (lastRefreshDate != nil &&
        ([[NSDate date] timeIntervalSince1970] - [lastRefreshDate timeIntervalSince1970] < minRefreshTime))
        return;
    
    NSFileHandle *fh = [NSFileHandle alloc];
    NSTask *mountTask = [NSTask alloc];
    NSString *mountcmd = [[NSString alloc] initWithString:@"/sbin/mount"];
    NSArray *argsArray = [NSArray arrayWithObjects:@"-t", @"osxfusefs", nil];
    NSString *mountOutput;
    if ([libFunctions execWithSocket:mountcmd arguments:argsArray env:nil io:fh proc:mountTask]) {
        [mountTask waitUntilExit];
        if (![libFunctions fileHandleIsReadable:fh]) {
            [mountedFuseVolumes removeAllObjects]; // clear existing array
            return;
        }

        NSData *bytes = [fh availableData];
        mountOutput = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
        
        [fh closeFile];
    } else {
        DDLogVerbose(@"Could not exec mount -t osxfusefs");
    }
        
    [mountedFuseVolumes removeAllObjects]; // clear existing array

    NSMutableArray * mountLines = [[NSMutableArray alloc] initWithArray:[mountOutput componentsSeparatedByString:@"\r\n"] copyItems: YES];
    
    NSLog(@"Got %lu lines from mount", [mountLines count]);
    
    for (NSString *line in mountLines) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression         
                                      regularExpressionWithPattern:@"^YoucryptFS on (.*) \\(osxfusefs*"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        [regex enumerateMatchesInString:line options:0 range:NSMakeRange(0, [line length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
             NSLog(@"Matched Volume [%@]", [line substringWithRange:[match rangeAtIndex:1]]);
            [mountedFuseVolumes addObject:[line substringWithRange:[match rangeAtIndex:1]]];
        }];
    }
	    
    lastRefreshDate = [NSDate date];
 
}

//#include <stdio.h>
//#include <fstab.h>
//+ (NSArray*) getFSEnt
//{
//    NSMutableArray *output = [[NSMutableArray alloc] init];
//
//    struct fstab *f = NULL;
//    
//    if (setfsent() == 0) 
//        return nil;
//    
//    while (1) {
//        f = getfsspec("osxfusefs");
//        if (f == NULL) break;
//        
//        printf("fs_spec: %s, "
//               "fs_file: %s, "
//               "fs_vfstype: %s, "
//               "fs_mntops: %s, "
//               "fs_type: %s, "
//               "fs_freq: %d, "
//               "fs_passno: %d\n", 
//               f->fs_spec, f->fs_file, f->fs_vfstype,
//               f->fs_mntops, f->fs_type, f->fs_freq, 
//               f->fs_passno);
//        [output addObject:[NSString stringWithCString:f->fs_file encoding:NSASCIIStringEncoding]];
//    }
//    endfsent();
//    
//    return output;
//
//}

@end

