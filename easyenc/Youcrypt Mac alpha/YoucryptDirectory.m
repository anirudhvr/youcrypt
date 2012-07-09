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
#import "PeriodicActionTimer.h"

@implementation YoucryptDirectory

@synthesize path;
@synthesize mountedPath;
@synthesize alias;
@synthesize mountedDateAsString;
@synthesize status;

static BOOL globalsAllocated = NO;
static NSMutableArray *mountedFuseVolumes;
static int minRefreshTime = 2; // at most every 30 seconds


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
        timer = [[PeriodicActionTimer alloc] initWithMinRefreshTime:minRefreshTime];
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
    
    if (status != YoucryptDirectoryStatusProcessing) {
        if (status == YoucryptDirectoryStatusSourceNotFound) {
            path = mountedPath = [NSString stringWithString:@""];
        } else if (status == YoucryptDirectoryStatusNotFound) {
            mountedPath = [NSString stringWithString:@""];
            status = YoucryptDirectoryStatusUnmounted; // source exists, just not mounted
        }
    }
}

- (BOOL)checkYoucryptDirectoryStatus:(BOOL)forceRefresh
{  
    @synchronized(self) {
        
        if (forceRefresh || [timer timerElapsed]) {
            [YoucryptDirectory refreshMountedFuseVolumes];
        }
        
    }
    
    NSUInteger indexOfPath = [mountedFuseVolumes indexOfObject:mountedPath];
    BOOL isDir = NO;
    BOOL sourcedirExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil];
    BOOL mountpathExists = [[NSFileManager defaultManager] fileExistsAtPath:mountedPath isDirectory:&isDir];
    
    if (!sourcedirExists) {
        status = YoucryptDirectoryStatusSourceNotFound;
        return NO;
    }
    
    if (status == YoucryptDirectoryStatusMounted) {         // Directory was mounted last we checked
        if (indexOfPath == NSNotFound) {                    // Not mounted any more 
            if (!mountpathExists) {                               // mount point has been removed
                status = YoucryptDirectoryStatusNotFound;
            } else {                                        // mount point exists, but is just not mounted
                status = isDir ? YoucryptDirectoryStatusUnmounted : YoucryptDirectoryStatusSourceNotFound;
            }
        }
    } else if (status == YoucryptDirectoryStatusUnmounted) {// Directory was umounted/closed 
        if (indexOfPath != NSNotFound) {                    // Surprise -- an umounted folder has been surprisingly mounted
            status = YoucryptDirectoryStatusMounted;
        } else {                                            // Still not mounted
            if (!mountpathExists)                                 // If dir is missing
                status = YoucryptDirectoryStatusNotFound;    
            else if (!isDir)                                // mountedPath is not a dir (!)
                status = YoucryptDirectoryStatusSourceNotFound;
            else                                            // Path still exists; no change in status
                status = YoucryptDirectoryStatusUnmounted;
        }
    }
    return YES;
}



// Refreshes the static variable mountedFuseVolumes at most every 5 minutes

+ (void) refreshMountedFuseVolumes 
{
    NSFileHandle *fh = [NSFileHandle alloc];
    NSTask *mountTask = [NSTask alloc];
    NSString *mountcmd = [[NSString alloc] initWithString:@"/sbin/mount"];
    NSArray *argsArray = [NSArray arrayWithObjects:@"-t", @"osxfusefs", nil];
    NSString *mountOutput;
    
    [mountedFuseVolumes removeAllObjects]; // clear existing array
    
    if ([libFunctions execWithSocket:mountcmd arguments:argsArray env:nil io:fh proc:mountTask]) {
        [mountTask waitUntilExit];
        if (![libFunctions fileHandleIsReadable:fh])
            return; // mount returned no matching lines

        NSData *bytes = [fh availableData];
        mountOutput = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
        
        [fh closeFile];
    } else {
        DDLogVerbose(@"Could not exec mount -t osxfusefs");
        return;
    }
        

    NSMutableArray *mountLines = [[NSMutableArray alloc] initWithArray:[mountOutput componentsSeparatedByString:@"\r\n"]];
    
    //NSLog(@"Got %lu lines from mount", [mountLines count]);
    
    for (NSString *line in mountLines) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression         
                                      regularExpressionWithPattern:@"^YoucryptFS on (.*) \\(osxfusefs*"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        [regex enumerateMatchesInString:line options:0 range:NSMakeRange(0, [line length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
           //  NSLog(@"Matched Volume [%@]", [line substringWithRange:[match rangeAtIndex:1]]);
            [mountedFuseVolumes addObject:[line substringWithRange:[match rangeAtIndex:1]]];
        }];
    }
}

+ (NSString*) statusToString:(NSUInteger)status
{
    switch(status) {
        case YoucryptDirectoryStatusNotFound:
            return [NSString stringWithString:@"Directory not found"];
            break;
        case YoucryptDirectoryStatusMounted:
            return [NSString stringWithString:@"Open"];
            break;
        case YoucryptDirectoryStatusUnmounted:
            return [NSString stringWithString:@"Closed"];
            break;
        case YoucryptDirectoryStatusProcessing:
            return [NSString stringWithString:@"Processing"];
            break;
        case YoucryptDirectoryStatusSourceNotFound:
            return [NSString stringWithString:@"Source directory not found"];
            break;
        default:
            return nil;
    }
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

