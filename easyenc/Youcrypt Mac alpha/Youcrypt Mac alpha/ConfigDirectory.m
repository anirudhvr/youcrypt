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
    
    firstRun = NO;
    NSString *homedir = NSHomeDirectory();
    
    youCryptVolDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/tmp"];
    youCryptTmpDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/volumes"];
    youCryptLogDir = [homedir stringByAppendingFormat:@"/.youcrypt/logs"];
    youCryptListFile = [homedir stringByAppendingPathComponent:@"/.youcrypt/dirs.plist"];
    
    
    if(![[NSFileManager alloc] fileExistsAtPath:[homedir stringByAppendingPathComponent:@"/.youcrypt"]]) {
        firstRun = YES;
    }
    else {
        mkdirRecursive(youCryptVolDir);
        mkdirRecursive(youCryptTmpDir);
        mkdirRecursive(youCryptLogDir);
    }
    return self;
}

-(NSString*)getLogDir
{
    return youCryptLogDir;
}
@end
