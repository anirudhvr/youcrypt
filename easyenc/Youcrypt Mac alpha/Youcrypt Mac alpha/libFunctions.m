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

@implementation libFunctions


+ (NSString*)getPassphraseFromKeychain:(NSString*)service;
{
    NSError *error = nil;
    NSString *passphraseFromKeychain = [SSKeychain passwordForService:service account:NSUserName() error:&error];
    
    if (error) {
        NSLog(@"Did not get passphrase");
        return nil;
    } else {
        NSLog(@"Got passphrase");
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
        [io initWithFileDescriptor:sockDescriptors[1] closeOnDealloc:NO];
    }
    if (proc == nil)
        proc = [[NSTask alloc] init];
    else {
        [proc init];
    }

     if (arguments != nil)
        [proc setArguments:arguments];
    if (env != nil)
        [proc setEnvironment:env];
    [proc setStandardInput:childFD];
    [proc setStandardOutput:childFD];
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


+ (BOOL) createEncFS:(NSString *)encFolder
     decryptedFolder:(NSString *)decFolder
            numUsers:(int)numUsers
    combinedPassword:(NSString *)pwd {

    NSTask *encfsProc = [NSTask alloc];
    NSFileHandle *io = [NSFileHandle alloc];
    
    if ([libFunctions execWithSocket:@"/usr/local/bin/encfs" arguments:nil env:nil io:io proc:encfsProc]) {        
        [io writeData:[[NSString stringWithFormat:@"8\nencfs\n--nu\n%d\n--pw\n%@\n--\n%@\n%@\n",
                        numUsers, pwd, encFolder, decFolder] dataUsingEncoding:NSUTF8StringEncoding]];
        [io closeFile];
        [encfsProc waitUntilExit];
        return YES;
    }
    else {
        return NO;
    }
    
}

+ (BOOL) mountEncFS:(NSString *)encFolder
    decryptedFolder:(NSString *)decFolder
           password:(NSString *)password {
    NSTask *encfsProc = [NSTask alloc];
    NSFileHandle *io = [NSFileHandle alloc];
    
    if ([libFunctions execWithSocket:@"/usr/local/bin/encfs" arguments:nil env:nil io:io proc:encfsProc]) {        
        [io writeData:[[NSString stringWithFormat:@"6\nencfs\n--pw\n%@\n--\n%@\n%@\n", 
                        password, encFolder, decFolder] dataUsingEncoding:NSUTF8StringEncoding]];
        [io closeFile];
        [encfsProc waitUntilExit];
        return YES;
    }
    else {
        return NO;
    }

}

@end
