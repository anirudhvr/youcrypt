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


+ (BOOL) createEncFS:(NSString *)encFolder
     decryptedFolder:(NSString *)decFolder
            numUsers:(int)numUsers
    combinedPassword:(NSString *)pwd
    encryptFilenames:(BOOL)encryptfilenames
{

    NSTask *encfsProc = [NSTask alloc];
    NSFileHandle *io = [NSFileHandle alloc];
    NSString *encfsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:ENCFS];
    
    NSDictionary *newenvsetting = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle mainBundle] resourcePath], @"DYLD_LIBRARY_PATH", nil];
    [encfsProc setEnvironment:newenvsetting];
    
    NSDictionary *env = [encfsProc environment];
    //DDLogVerbose(@"createEncfs: getenv : %@",env);
    
    //DDLogVerbose(@"ENCFSPATH : %@",encfsPath);
    if ([libFunctions execWithSocket:encfsPath arguments:nil env:env io:io proc:encfsProc]) {    
        int count = 9;
        
        NSString *encryptfilenames_s = @"";
        if (encryptfilenames) {
            encryptfilenames_s = [encryptfilenames_s stringByAppendingString:@"--enable-filename-encryption\n"];
            count++;
        }
        
        NSString *encfsArgs = [NSString stringWithFormat:@"%d\nencfs\n--nu\n%d\n--pw\n%@\n%@--\n%@\n%@\n-ofsname=YoucryptFS\n",
                               count, numUsers, pwd, encryptfilenames_s, encFolder, decFolder];

        
        //DDLogVerbose(@"encfsargs\n%@",encfsArgs);
        [io writeData:[encfsArgs dataUsingEncoding:NSUTF8StringEncoding]];
        [encfsProc waitUntilExit];
        //DDLogVerbose(@"SUCCESS");

        [io closeFile];
        return YES;
    }
    else {
        DDLogVerbose(@"FAIL");
        return NO;
    }
    
}


+ (BOOL) mountEncFS:(NSString *)encFolder 
    decryptedFolder:(NSString *)decFolder 
           password:(NSString*)password 
            fuseOptions:(NSDictionary*)fuseOpts
           idleTime:(int)idletime

{
    NSTask *encfsProc = [NSTask alloc];
    NSFileHandle *io = [NSFileHandle alloc];

    
    NSMutableArray *fuseopts = [[NSMutableArray alloc] init];
    
    for (NSString *key in [fuseOpts allKeys]) {
        if ([key isEqualToString:@"volname"]) {
            [fuseopts addObject:[NSString stringWithFormat:@"-ovolname=%@", [fuseOpts objectForKey:key]]];
        } else if ([key isEqualToString:@"volicon"]) {
            [fuseopts addObject:[NSString stringWithFormat:@"-ovolicon=%@/Contents/Resources/%@", [libFunctions appBundlePath], [fuseOpts objectForKey:key]]];
        } else { 
            [fuseopts addObject:[NSString stringWithFormat:@"-o%@=%@", key, [fuseOpts objectForKey:key]]];
        }
    }
    [fuseopts addObject:@"-ofsname=YoucryptFS"];
    NSString *encfsPath = [[[NSBundle mainBundle] resourcePath] 
                           stringByAppendingPathComponent:ENCFS]; 
    
    NSDictionary *newenvsetting = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle mainBundle] resourcePath], @"DYLD_LIBRARY_PATH", nil];
    [encfsProc setEnvironment:newenvsetting];
    NSDictionary *env = [encfsProc environment];
    //DDLogInfo(@"mountEncfs: getenv : %@",env);
    
    if ([libFunctions execWithSocket:encfsPath arguments:nil env:env io:io proc:encfsProc]) { 
        long count = 6 + [fuseopts count];
        
        NSString *idletime_s = @"";
        if (idletime > 0) {
            idletime_s = [idletime_s stringByAppendingFormat:@"--idle=%d\n", idletime];
            count++;
        }
                
        NSString *str = [NSString stringWithFormat:@"%ld\nencfs\n--pw\n%@\n%@--\n%@\n%@\n%@\n", 
                         count, password, idletime_s, encFolder, decFolder, [fuseopts componentsJoinedByString:@"\n"]];
        //DDLogInfo(@"mountEncfs: Decrypt args : %@",str);
        
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
                        
        //NSFileHandle *err = [encfsProc standardError];
        [io writeData:data];
        [encfsProc waitUntilExit];
        [io closeFile];
        if ([encfsProc terminationStatus]) {
            return NO;
        } else  {
            return YES;
        }
    }
    else {
        return NO;
    }
}

+ (BOOL) mountEncFS:(NSString *)encFolder
    decryptedFolder:(NSString *)decFolder
           password:(NSString *)password
         volumeName:(NSString*) volname         {
    
    NSTask *encfsProc = [NSTask alloc];
    NSFileHandle *io = [NSFileHandle alloc];
    NSString *vol = [NSString stringWithString:(volname == nil ? @"Youcrypt Volume" : volname)];
    NSString *encfsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:ENCFS]; 
    
    NSDictionary *newenvsetting = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle mainBundle] resourcePath], @"DYLD_LIBRARY_PATH", nil];
    [encfsProc setEnvironment:newenvsetting];
    NSDictionary *env = [encfsProc environment];

    if ([libFunctions execWithSocket:encfsPath arguments:nil env:env io:io proc:encfsProc]) {   
        NSString *args = [NSString stringWithFormat:@"8\nencfs\n--pw\n%@\n--\n%@\n%@\n-ofsname=YoucryptFS\n-ovolname=%@\n", 
                          password, encFolder, decFolder, vol];
        [io writeData:[args dataUsingEncoding:NSUTF8StringEncoding]];
        [encfsProc waitUntilExit];
        [io closeFile];
        if ([encfsProc terminationStatus])
            return NO;
        else 
            return YES;
    }
    else {
        return NO;
    }

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

+ (void) archiveDirectoryList:(id)directories 
                       toFile:(NSString*)file 
{
    [NSKeyedArchiver archiveRootObject:directories toFile:file];

}

+ (id) unarchiveDirectoryListFromFile:(NSString*)file
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:file];    
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


#include <string>
#include <iostream>
#include "encfs-core/YoucryptFolder.h"
#include "encfs-core/Credentials.h"
#include "encfs-core/PassphraseCredentials.h"

using std::cout;
using std::string;
using std::endl;
using namespace youcrypt;

+ (BOOL) openEncryptedFolder:(NSString*)srcFolder
                  mountPoint:(NSString*)destFolder
                  passphrase:(NSString*)pp
                    idleTime:(int)idletime
                    fuseOpts:(NSDictionary*)fuseOpts
{
    BOOL ret = YES;
    const char *srcfolder = [[srcFolder stringByAppendingString:@"/"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *destfolder = [destFolder cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pass = [pp cStringUsingEncoding:NSASCIIStringEncoding];
    
    std::vector<std::string> fuse_opts;
    
    path src(srcfolder);
    path dst(destfolder);
    create_directories(dst);
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials(pass));
    
    if (idletime > 0) {
        opts.idleTracking = true;
        opts.idleTrackingTimeOut = idletime;
    }
    
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
         
    YoucryptFolder folder(src, opts, creds);
    
    if (folder.currStatus() == YoucryptFolder::initialized) {
        // import worked  -- this is a Youcrypt folder
        folder.mount(dst, fuse_opts);
        if (folder.currStatus() != YoucryptFolder::mounted) {
            DDLogInfo(@"Mounting %@ at %@ failed!", srcFolder, destFolder);
            ret = NO;
        }
    }
    
    return ret;
}


+ (BOOL)encryptFolderInPlace:(NSString*) srcFolder
                  passphrase:(NSString*)pp
            encryptFilenames:(BOOL)encfnames
{
    const char *srcfolder = [[srcFolder stringByAppendingString:@"/"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pass = [pp cStringUsingEncoding:NSASCIIStringEncoding];
    BOOL ret = YES;
    
    path ph = boost::filesystem::temp_directory_path() / boost::filesystem::unique_path();
    create_directories(ph);
    NSString *tempFolder = [NSString stringWithCString:ph.string().c_str()];
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials(pass));
    
    if (encfnames)
        opts.filenameEncryption = YoucryptFolderOpts::filenameEncrypt;
    
    YoucryptFolder folder(ph, opts, creds);
    
    if (folder.importContent(path(srcfolder))) {
        // succeeded
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:srcFolder error:nil];
        NSError *err;
        // Remove everything in the source folder except for the encrypted folder
        for (NSString *file in files) {
            if (!([file isEqualToString:@"."] || [file isEqualToString:@".."])) {
                if (![fm removeItemAtPath:[srcFolder stringByAppendingPathComponent:file] error:&err]) {
                    DDLogInfo(@"Error removing dir: %@", [err localizedDescription]);
                    ret = NO;
                }
            }
        }
        
        // Move everything from the encrypted folder back to the source folder
        files = [fm contentsOfDirectoryAtPath:tempFolder error:nil];
        for (NSString *file in files) {
            if (![fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file]
                             toPath:[srcFolder stringByAppendingPathComponent:file] error:&err]) {
                DDLogInfo(@"Error moving contents: %@", [err localizedDescription]);
                ret = NO;
            }
        }
    } else {
        DDLogInfo(@"Encrypt: could not import content of %@ to temp folder /%@", srcFolder, ENCRYPTION_TEMPORARY_FOLDER);
        ret = NO;
    }
    
    return ret;
}

+ (int) testImportExport
{
    // Write test program below
    std::string encRoot = "/tmp/d/";
    string srcFolder = "/tmp/s";
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials("yet_another"));
    cout << "Encrypted Folder is " << encRoot << endl;
    opts.filenameEncryption = YoucryptFolderOpts::filenameEncrypt;
    YoucryptFolder folder(path(encRoot), opts, creds);
    
    string destSuffix = path(srcFolder).filename().string();
    cout << "Encrypting contents of " << srcFolder << " into " << encRoot << endl
          << "at " << "/" << destSuffix << endl;    
    folder.importContent(path(srcFolder), "/try");
    folder.exportContent(path("/tmp/gen"), "/");
    folder.mount(path("/tmp/mounted"));
    sleep(10);
    folder.unmount();
    
    return 0;
}


@end
