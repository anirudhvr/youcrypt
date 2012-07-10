//
//  libFunctions.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "libFunctions.h"

#import "SSKeychain.h"
#import "logging.h"
#import "pipetest.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"
#import <errno.h>

#define ENCFS @"/usr/local/bin/encfs"
#define ENCFSCTL @"/usr/local/bin/encfsctl"

@implementation libFunctions


+ (NSString*)getPassphraseFromKeychain:(NSString*)service;
{
    NSError *error = nil;
    NSString *passphraseFromKeychain = [SSKeychain passwordForService:service account:NSUserName() error:&error];
    
    if (error) {
        NSLog(@"Did not get passphrase");
        return nil;
    } else {
        NSLog(@"Got passphrase from keychain %", passphraseFromKeychain);
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
        NSLog(@"%@",[error localizedDescription]);
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

+ (void) mkdirRecursive:(NSString *)path {
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}



/**
 
 mvRecursive
 
 Recursively move contents of one directory to another
 
 pathFrom - directory whose contents we're moving
 pathTo - directory to where we're moving the contents
 
 **/

+(void) mvRecursive:(NSString *)srcPath toPath:(NSString *)dstPath {
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
    
    if ([libFunctions execWithSocket:ENCFS arguments:nil env:nil io:io proc:encfsProc]) {        
        int count = 8;
        
        NSString *encryptfilenames_s = [[NSString alloc] initWithString:@""];
        if (encryptfilenames) {
            encryptfilenames_s = [encryptfilenames_s stringByAppendingString:@"--enable-filename-encryption\n"];
            count++;
        }
        
        [io writeData:[[NSString stringWithFormat:@"8\nencfs\n--nu\n%d\n--pw\n%@\n%@--\n%@\n%@\n",
                        numUsers, pwd, encryptfilenames_s, encFolder, decFolder] dataUsingEncoding:NSUTF8StringEncoding]];
        [encfsProc waitUntilExit];
        [io closeFile];
        return YES;
    }
    else {
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

    if ([libFunctions execWithSocket:ENCFS arguments:nil env:nil io:io proc:encfsProc]) { 
        int count = 6 + [fuseopts count];
        
        NSString *idletime_s = [[NSString alloc] initWithString:@""];
        if (idletime > 0) {
            idletime_s = [idletime_s stringByAppendingFormat:@"--idle=%d\n", idletime];
            count++;
        }
                
        NSString *str = [NSString stringWithFormat:@"%d\nencfs\n--pw\n%@\n%@--\n%@\n%@\n%@\n", 
                         count, password, idletime_s, encFolder, decFolder, [fuseopts componentsJoinedByString:@"\n"]];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
                        
        NSFileHandle *err = [encfsProc standardError];
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
    
    if ([libFunctions execWithSocket:ENCFS arguments:nil env:nil io:io proc:encfsProc]) {        
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
    
    if ([libFunctions execWithSocket:ENCFSCTL arguments:[NSArray arrayWithObjects:@"autopasswd", path, nil] env:nil io:io proc:encfsProc]) {
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

+ (NSString*) appBundlePath 
{
    return [[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]] path];
}



@end
