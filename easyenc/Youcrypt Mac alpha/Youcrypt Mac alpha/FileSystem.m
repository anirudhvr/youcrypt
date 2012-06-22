//
//  FileSystem.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileSystem.h"
#import "logging.h"

@implementation FileSystem

@synthesize originalPath;
@synthesize mountedPath;
@synthesize isMounted;

- (id) init
{
    self = [super init];
    return self;
    DDLogVerbose(@"FS Init");
}



@end
