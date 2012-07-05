//
//  YoucryptConfigDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/20/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "ConfigDirectory.h"
#import "libFunctions.h"
#import "logging.h"

@implementation ConfigDirectory

@synthesize youCryptVolDir;
@synthesize youCryptTmpDir;
@synthesize youCryptLogDir;
@synthesize youCryptLockFile;
@synthesize youCryptListFile;
@synthesize firstRun;

-(id)init
{
    self = [super init];
    
    NSString *homedir = NSHomeDirectory();
    
    youCryptVolDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/volumes"];
    youCryptTmpDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/tmp"];
    youCryptLogDir = [homedir stringByAppendingFormat:@"/.youcrypt/logs"];
    youCryptListFile = [homedir stringByAppendingPathComponent:@"/.youcrypt/dirs.plist"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:[homedir stringByAppendingPathComponent:@"/.youcrypt"]]) {
        firstRun = YES;
        [libFunctions mkdirRecursive:youCryptLogDir];
        [libFunctions mkdirRecursive:youCryptVolDir];
        [libFunctions mkdirRecursive:youCryptTmpDir];
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
