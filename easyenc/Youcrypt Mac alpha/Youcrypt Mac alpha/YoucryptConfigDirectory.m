//
//  YoucryptConfigDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/20/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "YoucryptConfigDirectory.h"
#import "libFunctions.h"

@implementation YoucryptConfigDirectory

@synthesize youCryptVolDir;
@synthesize youCryptTmpDir;

-(id)init
{
	self = [super init];
    
    NSString *homedir = NSHomeDirectory();
    
    youCryptVolDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/tmp"];
    youCryptTmpDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/volumes"];
    
    mkdirRecursive(youCryptVolDir);
    mkdirRecursive(youCryptTmpDir);
    
    
    return self;
}

@end
