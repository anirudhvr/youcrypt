//
//  YoucryptDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoucryptDirectory.h"

@implementation YoucryptDirectory

@synthesize path;
@synthesize mountedPath;
@synthesize mounted;
@synthesize alias;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self != nil) {
        path = [decoder decodeObjectForKey:@"path"];
        mountedPath = [decoder decodeObjectForKey:@"mountedPath"];
        mounted = [decoder decodeBoolForKey:@"mounted"];
        alias = [decoder decodeObjectForKey:@"alias"];
        if (!alias)
            alias = [[NSString alloc] init];
        if ([alias isEqualToString:@""]) {
            alias = [path lastPathComponent];
        }
        NSLog(@"\n;;");
        NSLog(alias);
        NSLog(@";;\n");
        NSLog([path lastPathComponent]);
        NSLog(@"\n");
    }
    return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:path forKey:@"path"];
    [encoder encodeObject:mountedPath forKey:@"mountedPath"];
    [encoder encodeBool:mounted forKey:@"mounted"];
    [encoder encodeObject:alias forKey:@"alias"];
}

@end

