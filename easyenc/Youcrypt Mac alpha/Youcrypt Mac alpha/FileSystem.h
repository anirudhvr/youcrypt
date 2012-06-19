//
//  FileSystem.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSystem : NSObject {
    int type;
    
    NSString *originalPath;
    NSString *mountedPath;
    
    BOOL isMounted;
}

@property (readwrite,copy) NSString *originalPath;
@property (readwrite,copy) NSString *mountedPath;
@property (readwrite) BOOL isMounted;

@end
