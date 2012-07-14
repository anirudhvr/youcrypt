//
//  libFunctions.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "libFunctions.h"

#import "contrib/SSKeychain/SSKeychain.h"
#import "contrib/Lumberjack/logging.h"
#import <errno.h>
#import <CommonCrypto/CommonDigest.h>

#define ENCFS @"/yc-encfs"
#define ENCFSCTL @"/yc-encfsctl"

@implementation libFunctions


+ (NSString*)getPassphraseFromKeychain:(NSString*)service;
{
    NSError *error = nil;
    NSString *passphraseFromKeychain = [SSKeychain passwordForService:service account:NSUserName() error:&error];
    
    if (error) {
        NSLog(@"Did not get passphrase");
        return nil;
    } else {
        //NSLog(@"Got passphrase from keychain %@", passphraseFromKeychain);
        return passphraseFromKeychain;
    }
}


/* Register password with Mac keychain */
+ (BOOL)registerWithKeychain:(NSString*)passphrase:(NSString*)service;
{
    NSString *yourPasswordString = passphrase;
    NSError *error = nil;
    if([SSKeychain setPassword:yourPasswordString forService:service account:NSUserName() error:&error])
        NSLog(@"Successfully registered passphrase wiht keychain");
    if (error) {
        NSLog(@"Error registering with Keychain");
        NSLog(@"Register Keychain Error: %@",[error localizedDescription]);
        return NO;
    }
    return YES;
}




//NSString* systemCall(NSString *binary, NSArray *arguments) {
//    NSTask *task;   
//    task = [[NSTask alloc] init];
//    [task setLaunchPath: binary];
//    
//    [task setArguments: arguments];
//    
//    NSPipe *pipe;
//    pipe = [NSPipe pipe];
//    [task setStandardOutput: pipe];
//    
//    [task launch];
//    
//    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
//    
//    [task waitUntilExit]; 
//    //[task release];
//    
//    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
//    
//    //DDLogVerbose (@"got\n%@", string); 
//    
//    return string;
//}

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
    [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:nil];
    
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
    NSLog(@"getenv : %@",env);
    
    NSLog(@"ENCFSPATH : %@",encfsPath);
    if ([libFunctions execWithSocket:encfsPath arguments:nil env:env io:io proc:encfsProc]) {    
        int count = 8;
        
        NSString *encryptfilenames_s = [[NSString alloc] initWithString:@""];
        if (encryptfilenames) {
            encryptfilenames_s = [encryptfilenames_s stringByAppendingString:@"--enable-filename-encryption\n"];
            count++;
        }
        
        NSString *encfsArgs = [NSString stringWithFormat:@"%d\nencfs\n--nu\n%d\n--pw\n%@\n%@--\n%@\n%@\n",
                               count, numUsers, pwd, encryptfilenames_s, encFolder, decFolder];
        
        NSLog(@"encfsargs\n%@",encfsArgs);
        [io writeData:[encfsArgs dataUsingEncoding:NSUTF8StringEncoding]];
        [encfsProc waitUntilExit];
        NSLog(@"SUCCESS");

        [io closeFile];
        return YES;
    }
    else {
        NSLog(@"FAIL");
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
    [fuseopts addObject:[NSString stringWithString:@"-ofsname=YouCryptFS"]];
    NSString *encfsPath = [[[NSBundle mainBundle] resourcePath] 
                           stringByAppendingPathComponent:ENCFS]; 
    
    NSDictionary *newenvsetting = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle mainBundle] resourcePath], @"DYLD_LIBRARY_PATH", nil];
    [encfsProc setEnvironment:newenvsetting];
    
    NSDictionary *env = [encfsProc environment];
    NSLog(@"getenv : %@",env);
    
    if ([libFunctions execWithSocket:encfsPath arguments:nil env:env io:io proc:encfsProc]) { 
        int count = 6 + [fuseopts count];
        
        NSString *idletime_s = [[NSString alloc] initWithString:@""];
        if (idletime > 0) {
            idletime_s = [idletime_s stringByAppendingFormat:@"--idle=%d\n", idletime];
            count++;
        }
                
        NSString *str = [NSString stringWithFormat:@"%d\nencfs\n--pw\n%@\n%@--\n%@\n%@\n%@\n", 
                         count, password, idletime_s, encFolder, decFolder, [fuseopts componentsJoinedByString:@"\n"]];
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
    if ([libFunctions execWithSocket:encfsPath arguments:nil env:nil io:io proc:encfsProc]) {        
        [io writeData:[[NSString stringWithFormat:@"8\nencfs\n--pw\n%@\n--\n%@\n%@\n-ofsname=YoucryptFS\n-ovolname=%@\n", 
                        password, encFolder, decFolder, vol] dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSLog(@"ENCFSCTL Path : %@",encfsctlPath);
    if ([libFunctions execWithSocket:encfsctlPath arguments:[NSArray arrayWithObjects:@"autopasswd", path, nil] env:nil io:io proc:encfsProc]) {
        [io writeData:[[NSString stringWithFormat:@"%@\n%@\n", oldPasswd, newPasswd] dataUsingEncoding:NSUTF8StringEncoding]];
        [encfsProc waitUntilExit];
        if ([encfsProc terminationStatus] == 0) {
            NSLog(@"ENCFSCTL SUCCEEDED!");
            return YES;
        }
        else {
            NSLog(@"ENCFSCTL FAILED!");
            return NO;
        }
    }
    else {
        NSLog(@"ENCFSCTL FAILED 2!");
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
    
    
    NSLog(@"Dropbox folder loc: %@",dropboxURL);
    return [dropboxURL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

+ (NSString*) appBundlePath 
{
    return [[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]] path];
}



@end
