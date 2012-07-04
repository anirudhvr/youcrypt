//
//  main.m
//  TestBed
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoucryptDirectory.h"
#import "libFunctions.h"



int main_dirs_plis(int argc, const char * argv[])
{
    @autoreleasepool {
        // Read config directory here.
        NSString *dirConfigPath = @"/Users/rajsekar/.youcrypt/config.plist";
        NSMutableArray *youcryptDirectories = [[NSMutableArray alloc] init];
        YoucryptDirectory *directory = [[YoucryptDirectory alloc] init];    
        [directory setPath:@"/Users/rajsekar/tmp/sth.yc"];
        [directory setMountedPath:@""];    
        [youcryptDirectories addObject:directory];
        directory = [[YoucryptDirectory alloc] init];    
        [directory setPath:@"/Users/rajsekar/tmp/sthelse.yc"];
        [directory setMountedPath:@"mounted path"];    
        [youcryptDirectories addObject:directory];
        directory = [[YoucryptDirectory alloc] init];    
        [directory setPath:@"/Users/rajsekar/tmp/sthmore.yc"];
        [directory setMountedPath:@""];    
        [youcryptDirectories addObject:directory];
        printf ("Count: %lu\n", youcryptDirectories.count);
        // Now, we write the data to config directory.
        [NSKeyedArchiver archiveRootObject:youcryptDirectories toFile:dirConfigPath];
        youcryptDirectories = [NSKeyedUnarchiver unarchiveObjectWithFile:dirConfigPath];
        printf ("Count: %lu\n", youcryptDirectories.count);
    }
    return 0;
}


int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSString *tmpFolder = NSTemporaryDirectory();
    }
    return 0;
}


