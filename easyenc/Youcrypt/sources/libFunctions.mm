//
//  libFunctions.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "libFunctions.h"

#import "contrib/SSKeychain/SSKeychain.h"
#import <errno.h>
#import <CommonCrypto/CommonDigest.h>

#define ENCFS @"/yc-encfs"
#define ENCFSCTL @"/yc-encfsctl"

#include <string>
#include "core/DirectoryMap.h"
#include <boost/filesystem/fstream.hpp>
#include "encfs-core/YoucryptFolder.h"
#include "encfs-core/Credentials.h"
#include "encfs-core/PassphraseCredentials.h"

using std::cout;
using std::string;
using std::endl;
using namespace youcrypt;


@implementation libFunctions


+ (BOOL) mkdirRecursive:(NSString *)path {
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

/**
 
 mvRecursive
 
 Recursively move contents of one directory to another
 
 pathFrom - directory whose contents we're moving
 pathTo - directory to where we're moving the contents
 
 **/

+(BOOL) mvRecursive:(NSString *)srcPath toPath:(NSString *)dstPath {
    return [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:nil];
}




// NSTask sets argv[0]; we do not need to pass that in arguments.
+ (BOOL) execWithSocket:(NSString *)path arguments:(NSArray *)arguments
                    env:(NSDictionary *)env
                     io:(NSFileHandle *)io 
                   proc:(NSTask *)proc {

    int sockDescriptors[2];
    if (socketpair(AF_LOCAL, SOCK_STREAM, 0, sockDescriptors) == -1)
        return NO;

    NSFileHandle *childFD = [[NSFileHandle alloc] initWithFileDescriptor:sockDescriptors[0] closeOnDealloc:NO];
    if (io == nil)
        io = [[NSFileHandle alloc] initWithFileDescriptor:sockDescriptors[1]];
    else {
        io = [io initWithFileDescriptor:sockDescriptors[1] closeOnDealloc:NO];
    }
    if (proc == nil)
        proc = [[NSTask alloc] init];
    else {
        proc = [proc init];
    }

    if (arguments != nil)
        [proc setArguments:arguments];
    if (env != nil)
        [proc setEnvironment:env];
    
    
    [proc setStandardInput:childFD];
    [proc setStandardOutput:childFD];
    [proc setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    [proc setLaunchPath:path];
    
    @try {
        [proc launch];
    }
    @catch (NSException *exception) {
        proc = nil;
        io = nil;
        return NO;
    }
    return YES;
}

+ (int) execCommand:(NSString *)path arguments:(NSArray *)arguments
                 env:(NSDictionary *)env {
    NSTask *proc = [NSTask alloc];
    if ([libFunctions execWithSocket:path arguments:arguments env:env io:nil proc:proc]) {
        [proc waitUntilExit];
        return [proc terminationStatus];
    }
    return -1;
}





+ (BOOL) changeEncFSPasswd:(NSString *)path
                 oldPasswd:(NSString *)oldPasswd
                 newPasswd:(NSString *)newPasswd {
   
    NSTask *encfsProc = [NSTask alloc];
    NSFileHandle *io = [NSFileHandle alloc];
    NSString *encfsctlPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:ENCFSCTL]; 

    DDLogInfo(@"changeEncfsPwd: ENCFSCTL Path : %@",encfsctlPath);
    
    NSDictionary *newenvsetting = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle mainBundle] resourcePath], @"DYLD_LIBRARY_PATH", nil];
    [encfsProc setEnvironment:newenvsetting];
    NSDictionary *env = [encfsProc environment];

    if ([libFunctions execWithSocket:encfsctlPath arguments:[NSArray arrayWithObjects:@"autopasswd", path, nil] env:env io:io proc:encfsProc]) {
        [io writeData:[[NSString stringWithFormat:@"%@\n%@\n", oldPasswd, newPasswd] dataUsingEncoding:NSUTF8StringEncoding]];
        [encfsProc waitUntilExit];
        if ([encfsProc terminationStatus] == 0) {
            DDLogInfo(@"changeEncfsPwd: ENCFSCTL SUCCEEDED!");
            return YES;
        }
        else {
            DDLogInfo(@"changeEncfsPwd: ENCFSCTL FAILED!");
            return NO;
        }
    }
    else {
        DDLogInfo(@"changeEncfsPwd: ENCFSCTL FAILED 2!");
        return NO;
    }
}



+ (BOOL)fileHandleIsReadable:(NSFileHandle*)fh
{
    int fd = [fh fileDescriptor];
    fd_set fdset;
    struct timeval tmout = { 0, 0 }; // return immediately
    FD_ZERO(&fdset);
    FD_SET(fd, &fdset);
    return (select(fd + 1, &fdset, NULL, NULL, &tmout) > 0);
}



+ (void) archiveDirectoryList:(boost::shared_ptr<DirectoryMap>)directories
                       toFile:(NSString*)file 
{
    string strFile([file cStringUsingEncoding:NSASCIIStringEncoding]);
    boost::filesystem::ofstream ofile(strFile);
    if (ofile.is_open()) {
        const DirectoryMap &dmap = *directories.get();
        ofile << dmap;
    }    
}

+ (boost::shared_ptr<DirectoryMap>) unarchiveDirectoryListFromFile:(NSString*)file
{
    boost::shared_ptr<DirectoryMap> dirs(new DirectoryMap);
    DirectoryMap &dmap = *dirs.get();
    string strFile([file cStringUsingEncoding:NSASCIIStringEncoding]);
    boost::filesystem::ifstream ifile(strFile);
    if (ifile.is_open()) {
        ifile >> dmap;
    }
    return dirs;
}

#include <stdio.h>

+ (NSString*) locateDropboxFolder
{
    NSString *bundlepath =[[NSBundle mainBundle] resourcePath];
    NSString *dropboxScript = [bundlepath stringByAppendingPathComponent:@"/get_dropbox_folder.sh"]; 
    NSString *dropboxURL = nil;
    
    // check if dropbox script exists and fail otherwise
    if (![[NSFileManager defaultManager] fileExistsAtPath:dropboxScript]) {
        DDLogVerbose(@"Cannot find dropbox locator script at %@", dropboxScript);
        return @"";
    }
   
    NSFileHandle *fh = [NSFileHandle alloc];
    NSTask *dropboxTask = [NSTask alloc];
    if ([self execWithSocket:dropboxScript arguments:nil env:nil io:fh proc:dropboxTask]) {
        [dropboxTask waitUntilExit];
        NSData *bytes = [fh availableData];
        dropboxURL = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
        [fh closeFile];
    } else {
        DDLogVerbose(@"Could not exec dropbox location finder script");
    }
    
   // dropboxURL = @"get_dropbox_folder.sh: Dropbox database not found, is dropbox installed?\n";
    NSLog(@"Dropbox folder loc: %@",dropboxURL);
    if (dropboxURL) {
        dropboxURL = [dropboxURL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *dbNotFoundRegex = @".*not found.*"; 
        NSPredicate *dbLocTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", dbNotFoundRegex]; 
        
        if ([dbLocTest evaluateWithObject:dropboxURL]) {
            DDLogVerbose(@"Dropbox not installed - location not found");
            dropboxURL = @"";
        }
    }
   
    return dropboxURL;
}

+ (NSString*) appBundlePath
{
    return [[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]] path];
}

+ (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:candidate];
}

#include <stdlib.h>
+ (NSString*) getRealPathByResolvingSymlinks:(NSString*) path
{
    const char *inPath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    char *output = NULL;
    
    if ((output = realpath(inPath, NULL))) {
        return [NSString stringWithCString:output encoding:NSASCIIStringEncoding];
    } else {
        return nil;
    }
}


+ (NSString*) findCurrentlySelectedDirInFinder
{
    NSString *source = [NSString stringWithFormat:@"tell application \"Finder\"\n"
                        "set selectedItems to selection\n"
                        "if ((count of selectedItems) > 0) then\n"
                        "set selectedItem to ((item 1 of selectedItems) as alias)\n"
                        "POSIX path of selectedItem\n"
                        "end if\n"
                        "end tell\n"];
    NSAppleScript *update=[[NSAppleScript alloc] initWithSource:source];
    NSDictionary *err;
    NSAppleEventDescriptor *ret = [update executeAndReturnError:&err];
    return [ret stringValue];
}

+ (NSString*) findCurrentlyOpenDirInFinder
{
    NSString *source = [NSString stringWithFormat:@"tell application \"Finder\"\n"
              "set selectedItems to selection\n"
              "POSIX path of (target of Finder window 1 as alias)\n"
              "end tell\n"];
    NSAppleScript *update = [[NSAppleScript alloc] initWithSource:source];
    NSDictionary *err;
    NSAppleEventDescriptor *ret = [update executeAndReturnError:&err];
    return  [ret stringValue];
}

+ (BOOL) openMountedPathInTopFinderWindow:(NSString*)diskName
{
    NSString *source=[NSString stringWithFormat:@"tell application \"Finder\"\n"
                      "activate\n"
                      "set target of Finder window 1 to disk \"%@\"\n"
                      "end tell\n", diskName];
    NSAppleScript *update=[[NSAppleScript alloc] initWithSource:source];
    NSDictionary *err;
    [update executeAndReturnError:&err];
    return (err == nil) ? YES : NO;
}

+ (BOOL) openMountedPathInFinderSomehow:(NSString*)sourcepath
                            mountedPath:(NSString*)mountedpath
{
    NSString *finderSelPath = [libFunctions findCurrentlySelectedDirInFinder];
    NSString *finderPath = [libFunctions findCurrentlyOpenDirInFinder];
    if (((finderPath != nil) && ([finderPath isEqualToString:[[sourcepath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/"]]))
        || ((finderPath != nil) && ([finderSelPath isEqualToString:[sourcepath stringByAppendingFormat:@"/"]]))) {
        if (![libFunctions openMountedPathInTopFinderWindow:mountedpath])
            [[NSWorkspace sharedWorkspace] openFile:mountedpath];
        
    } else {
        [[NSWorkspace sharedWorkspace] openFile:mountedpath];
    }
}

@end
