//
//  YoucryptDirectory.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoucryptDirectory : NSObject <NSCoding> {
}

@property (nonatomic, strong) NSString *path;          // Path of the youcrypt directory.
@property (nonatomic, strong) NSString *mountedPath;   // Path if the directory is mounted by us.
@property (nonatomic, assign) BOOL mounted;            // Is this mounted somewhere?
@property (nonatomic, strong) NSString *alias;         // Readable name (last path component?)

// Add more if needed.

@end

