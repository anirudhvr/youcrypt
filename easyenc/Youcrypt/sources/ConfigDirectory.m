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

      
    return self;
}

-(BOOL)isFirstRun
{
    NSString *homedir = NSHomeDirectory();
    if (![[NSFileManager defaultManager] fileExistsAtPath:youcryptUserUUID]) // this is created last in teh firstrunsuccessful method
        firstRun = YES;
    else
        firstRun = NO;
    return firstRun;
}

-(void)firstRunSuccessful
{    
    if (![libFunctions mkdirRecursive:youCryptLogDir]) {
        DDLogVerbose(@"First run: could not create youcrypt logdir");
    } else if (![libFunctions mkdirRecursive:youCryptVolDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt vol dir");
    } else if (![libFunctions mkdirRecursive:youCryptTmpDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt Tmp dir");
    } else {    
        NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        NSError *error;
        [uuid writeToFile:youcryptUserUUID atomically:YES encoding:NSASCIIStringEncoding error:&error];
        if(!error) {
            firstRun = NO;
        } else {
            DDLogVerbose(@"Could not create uuid.txt : %@",[error localizedDescription]);
        }
    }
}

-(NSString*)getLogDir
{
    return youCryptLogDir;
}
@end
