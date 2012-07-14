//
//  YoucryptConfigDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/20/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "ConfigDirectory.h"
#import "libFunctions.h"
#import "Contrib/Lumberjack/logging.h"

@implementation ConfigDirectory

@synthesize youCryptVolDir;
@synthesize youCryptTmpDir;
@synthesize youCryptLogDir;
@synthesize youCryptLockFile;
@synthesize youCryptListFile;
@synthesize firstRun;
@synthesize youcryptUserUUID;

-(id)init
{
    self = [super init];
    
    NSString *homedir = NSHomeDirectory();
    
    youCryptVolDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/volumes"];
    youCryptTmpDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/tmp"];
    youCryptLogDir = [homedir stringByAppendingFormat:@"/.youcrypt/logs"];
    youCryptListFile = [homedir stringByAppendingPathComponent:@"/.youcrypt/dirs.plist"];
    youcryptUserUUID = [homedir stringByAppendingPathComponent:@"/.youcrypt/uuid.txt"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:[homedir stringByAppendingPathComponent:@"/.youcrypt"]]) {
        firstRun = YES;
        [libFunctions mkdirRecursive:youCryptLogDir];
        [libFunctions mkdirRecursive:youCryptVolDir];
        [libFunctions mkdirRecursive:youCryptTmpDir];
        
        NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        NSError *error;
        [uuid writeToFile:youcryptUserUUID atomically:YES encoding:NSASCIIStringEncoding error:&error];
        if(error) {
            DDLogVerbose(@"Could not create uuid.txt : %@",[error localizedDescription]);
        }
        DDLogVerbose(@"Client has been assigned UUID: %@",uuid);
    } else {
        firstRun = NO;
    }
    
    
    return self;
}

-(NSString*)getLogDir
{
    return youCryptLogDir;
}
@end
