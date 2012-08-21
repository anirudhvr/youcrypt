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

#include <boost/filesystem/path.hpp>
#include <boost/filesystem/operations.hpp>
using boost::shared_ptr;
using std::cout;
using std::string;
using std::endl;
using namespace youcrypt;

@implementation YoucryptDirectory

@synthesize path;
@synthesize mountedPath;
@synthesize alias;
@synthesize mountedDateAsString;
//@synthesize status;

static BOOL globalsAllocated = NO;
static NSMutableArray *mountedFuseVolumes;
//static int minRefreshTime = 5; // at most every 30 seconds

- (id) initWithPath:(NSString*)p
{
    self = [super init];
    if (self != nil)
    {
        path = [NSString stringWithString:p];
        boost::filesystem::path ph([path cStringUsingEncoding:NSASCIIStringEncoding]);
        folder.reset(new YoucryptFolder(ph));
    }
    return self;
}
    
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self != nil) {
        path = [decoder decodeObjectForKey:@"path"];
        mountedPath = [decoder decodeObjectForKey:@"mountedPath"];
        alias = [decoder decodeObjectForKey:@"alias"];
        mountedDateAsString = [decoder decodeObjectForKey:@"mountedDateAsString"];
//        status = [decoder decodeIntegerForKey:@"status"];
        
        boost::filesystem::path ph([path cStringUsingEncoding:NSASCIIStringEncoding]);
        folder.reset(new YoucryptFolder(ph));
        
        if (!alias)
            alias = [[NSString alloc] init];
        
        if ([alias isEqualToString:@""]) {
            alias = [path lastPathComponent];
        }
        
//        @synchronized(self) {
//            if (globalsAllocated == NO) {
//                mountedFuseVolumes = [[NSMutableArray alloc] init];
//                [YoucryptDirectory refreshMountedFuseVolumes];
//                globalsAllocated = YES;
//            } 
//        }
    }
    return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:path forKey:@"path"];
    [encoder encodeObject:mountedPath forKey:@"mountedPath"];
    [encoder encodeObject:alias forKey:@"alias"];
    [encoder encodeObject:mountedDateAsString forKey:@"mountedDateAsString"];
//    [encoder encodeInteger:status forKey:@"status"];
}


- (BOOL)encryptFolderInPlaceWithPassphrase:(NSString*)pp
                          encryptFilenames:(BOOL)encfnames
{
    const char *srcfolder = [[path stringByAppendingString:@"/"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pass = [pp cStringUsingEncoding:NSASCIIStringEncoding];
    BOOL ret = YES;
    
    boost::filesystem::path ph = boost::filesystem::temp_directory_path() / boost::filesystem::unique_path();
    boost::filesystem::create_directories(ph);
    NSString *tempFolder = [NSString stringWithFormat:@"%s", ph.string().c_str()];
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials(pass));
    
    if (encfnames)
        opts.filenameEncryption = YoucryptFolderOpts::filenameEncrypt;
    
    folder.reset(new YoucryptFolder(ph, opts, creds));
    
    if (folder->importContent(boost::filesystem::path(srcfolder))) {
        // succeeded
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:path error:nil];
        NSError *err;
        // Remove everything in the source folder
        for (NSString *file in files) {
            if (!([file isEqualToString:@"."] || [file isEqualToString:@".."])) {
                if (![fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err]) {
                    DDLogInfo(@"Error removing dir: %@", [err localizedDescription]);
                    folder.reset();
                    ret = NO;
                }
            }
        }
        
        // Move everything from the encrypted folder back to the source folder
        files = [fm contentsOfDirectoryAtPath:tempFolder error:nil];
        for (NSString *file in files) {
            if (![fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file]
                             toPath:[path stringByAppendingPathComponent:file] error:&err]) {
                DDLogInfo(@"Error moving contents: %@", [err localizedDescription]);
                folder.reset();
                ret = NO;
            }
        }
    } else {
        DDLogInfo(@"Encrypt: could not import content of %@ to temp folder /%@", path, ENCRYPTION_TEMPORARY_FOLDER);
        folder.reset();
        ret = NO;
    }
    
    return ret;
}

- (BOOL) openEncryptedFolderAtMountPoint:(NSString*)destFolder
                          withPassphrase:(NSString*)pp
                                idleTime:(int)idletime
                                fuseOpts:(NSDictionary*)fuseOpts
{
    BOOL ret = YES;
    const char *srcfolder = [[path stringByAppendingString:@"/"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *destfolder = [destFolder cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pass = [pp cStringUsingEncoding:NSASCIIStringEncoding];
    std::vector<std::string> fuse_opts;
    boost::filesystem::path src(srcfolder);
    boost::filesystem::path dst(destfolder);
    
    if (folder == NULL ||
        (folder->currStatus() != YoucryptFolder::initialized))
        // ensure that this is a legit Youcrypt folder
        return NO;
    
    create_directories(dst);
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials(pass));
    
    if (idletime < 0)
        idletime = 0;
    for (NSString *key in [fuseOpts allKeys]) {
        NSString *opt;
        if ([key isEqualToString:@"volicon"]) {
            opt = [NSString stringWithFormat:@"-ovolicon=%@/Contents/Resources/%@", [libFunctions appBundlePath], [fuseOpts objectForKey:key]];
        } else {
            opt = [NSString stringWithFormat:@"-o%@=%@", key, [fuseOpts objectForKey:key]];
        }
        fuse_opts.push_back(std::string([opt cStringUsingEncoding:NSASCIIStringEncoding]));
    }
    fuse_opts.push_back(std::string("-ofsname=YoucryptFS"));
         
    bool m = folder->mount(dst, fuse_opts, idletime);
    if (!m || (folder->currStatus() != YoucryptFolder::mounted)) {
        DDLogInfo(@"Mounting %@ at %@ failed!", path, destFolder);
        ret = NO;
    }
    
    return ret;
}

- (BOOL)decryptFolderInPlaceWithPassphrase:(NSString *)pp
{
    const char *srcfolder = [[path stringByAppendingString:@"/"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pass = [pp cStringUsingEncoding:NSASCIIStringEncoding];
    BOOL ret = YES;
    
    boost::filesystem::path ph = boost::filesystem::temp_directory_path() / boost::filesystem::unique_path();
    create_directories(ph);
    NSString *tempFolder = [NSString stringWithFormat:@"%s",ph.string().c_str()];
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials(pass));
    
    if (folder->currStatus() == YoucryptFolder::mounted)
        if (!folder->unmount()) {
            ret = NO;
            goto getout;
        }
    
    // Nobody else should be using this
    assert(folder.use_count() == 1);
    
    // Export decrypted contents to temp dir
    if (folder->exportContent(ph)) {
        // success
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:path error:nil];
        NSError *err;
        // Remove everything in the source folder
        for (NSString *file in files) {
            if (!([file isEqualToString:@"."] || [file isEqualToString:@".."])) {
                if (![fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err]) {
                    DDLogInfo(@"Error removing dir: %@", [err localizedDescription]);
                    ret = NO;
                }
            }
        }
        
        // Move everything from the decrypted folder back to the source folder
        files = [fm contentsOfDirectoryAtPath:tempFolder error:nil];
        for (NSString *file in files) {
            if (![fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file]
                             toPath:[path stringByAppendingPathComponent:file] error:&err]) {
                DDLogInfo(@"Error moving contents: %@", [err localizedDescription]);
                ret = NO;
            }
        }
    } else {
        DDLogInfo(@"decrypt: could not export content of %@ to temp folder /%@", path, ENCRYPTION_TEMPORARY_FOLDER);
        ret = NO;
    }
    
getout:
    return ret;
}

- (BOOL) closeEncryptedFolder
{
    if (folder->currStatus() == YoucryptFolder::mounted)
        folder->unmount();
    folder.reset();
}

- (int) status
{
    // A folder object should have been created for sure, with
    // status set to YoucryptFolder::statusUnkown
    assert(folder.get() != NULL);
    
    return folder->currStatus();
}

- (NSString*) getStatus
{
    // A folder object should have been created for sure, with
    // status set to YoucryptFolder::statusUnkown
    assert(folder.get() != NULL);
    
    return [NSString stringWithFormat:@"%s", folder->statusAsString()];
}

//- (void) updateInfo
//{
//    [self checkYoucryptDirectoryStatus:NO];
//}
//
//- (BOOL)checkYoucryptDirectoryStatus:(BOOL)forceRefresh
//{  
//    if (forceRefresh)
//        [YoucryptDirectory refreshMountedFuseVolumes];
//    
//    NSUInteger indexOfPath = [mountedFuseVolumes indexOfObject:mountedPath];
//    BOOL isDir = NO;
//    BOOL sourcedirExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil];
//    BOOL mountpathExists = [[NSFileManager defaultManager] fileExistsAtPath:mountedPath isDirectory:&isDir];
//    
//    if (status == YoucryptDirectoryStatusProcessing) // We don't handle this.
//        return YES;    
//    else if (!sourcedirExists) {
//        status = YoucryptDirectoryStatusSourceNotFound;
//        return YES;
//    }
//    else if (mountpathExists && indexOfPath != NSNotFound) {        
//        status = YoucryptDirectoryStatusMounted;
//        return YES;
//    }
//    else {
//        status = YoucryptDirectoryStatusUnmounted;
//        mountedPath = @"";
//        return YES;
//    }
//    
//    return YES;
//}

// Refreshes the static variable mountedFuseVolumes at most every 5 minutes
//+ (void) refreshMountedFuseVolumes
//{
//    NSFileHandle *fh = [NSFileHandle alloc];
//    NSTask *mountTask = [NSTask alloc];
//    NSArray *argsArray = [NSArray arrayWithObjects:@"-t", @"osxfusefs", nil];
//    NSString *mountOutput;
//    NSMutableArray *tmpMountedFuseVolumes = [[NSMutableArray alloc] init];
//    
//    
//    if ([libFunctions execWithSocket:MOUNT_CMD arguments:argsArray env:nil io:fh proc:mountTask]) {
//        [mountTask waitUntilExit];
//        if (![libFunctions fileHandleIsReadable:fh]) {
//            mountedFuseVolumes = tmpMountedFuseVolumes;
//            return;
//        }
//
//        NSData *bytes = [fh availableData];
//        mountOutput = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
//        
//        [fh closeFile];
//    } else {
//        DDLogVerbose(@"Could not exec mount -t osxfusefs");
//        return;
//    }
//        
//
//    NSMutableArray *mountLines = [[NSMutableArray alloc] initWithArray:[mountOutput componentsSeparatedByString:@"\n"]];
//    
//    
//    for (NSString *line in mountLines) {
//        NSError *error = NULL;
//        NSRegularExpression *regex = [NSRegularExpression         
//                                      regularExpressionWithPattern:@"^YoucryptFS on (.*) \\(osxfusefs*"
//                                      options:NSRegularExpressionCaseInsensitive
//                                      error:&error];
//        [regex enumerateMatchesInString:line options:0 range:NSMakeRange(0, [line length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
//            [tmpMountedFuseVolumes addObject:[line substringWithRange:[match rangeAtIndex:1]]];
//        }];
//     
//    }
//    [mountedFuseVolumes removeAllObjects]; // clear existing array
//    mountedFuseVolumes = tmpMountedFuseVolumes;
//    NSString *mnted;
//    DDLogInfo(@"Mounted fuse volumes:\n");
//    for (mnted in mountedFuseVolumes) {
//        DDLogInfo(@"mounted : %@\n", mnted);
//    }
//}

//+ (BOOL) pathIsMounted:(NSString *)path {
//    [YoucryptDirectory refreshMountedFuseVolumes];    
//    if ([mountedFuseVolumes indexOfObject:path] == NSNotFound)
//        return NO;
//    else {
//        return YES;
//    }
//}

//+ (NSString*) statusToString:(NSUInteger)status
//{
//    switch(status) {
//        case YoucryptDirectoryStatusNotFound:
//            return @"Directory not found";
//            break;
//        case YoucryptDirectoryStatusMounted:
//            return @"Open";
//            break;
//        case YoucryptDirectoryStatusUnmounted:
//            return @"Closed";
//            break;
//        case YoucryptDirectoryStatusProcessing:
//            return @"Processing";
//            break;
//        case YoucryptDirectoryStatusSourceNotFound:
//            return @"Source directory not found";
//            break;
//        default:
//            return nil;
//    }
//}

@end

