//
//  YoucryptConfigDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/20/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "YoucryptConfigDirectory.h"
#import "libFunctions.h"
#import "logging.h"

@implementation YoucryptConfigDirectory

@synthesize youCryptVolDir;
@synthesize youCryptTmpDir;
@synthesize youCryptLogDir;
@synthesize youCryptLockFile;
@synthesize youCryptListFile;

-(id)init
{
    self = [super init];
    
    NSString *homedir = NSHomeDirectory();
    
    youCryptVolDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/tmp"];
    youCryptTmpDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/volumes"];
    youCryptLogDir = [homedir stringByAppendingFormat:@"/.youcrypt/logs"];
    youCryptListFile = [homedir stringByAppendingPathComponent:@"/.youcrypt/dirs.plist"];
    
    mkdirRecursive(youCryptVolDir);
    mkdirRecursive(youCryptTmpDir);
    mkdirRecursive(youCryptLogDir);
    return self;
}

-(NSString*)getLogDir
{
    return youCryptLogDir;
}
@end
