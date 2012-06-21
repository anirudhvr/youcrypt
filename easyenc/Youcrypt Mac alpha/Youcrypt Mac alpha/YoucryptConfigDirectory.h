//
//  YoucryptConfigDirectory.h
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/20/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YoucryptFolderName @".youcrypt"

@interface YoucryptConfigDirectory : NSObject {

    NSString *youCryptVolDir;
    NSString *youCryptTmpDir;
    NSString *youcryptLockfile;
    BOOL needsCreation;
    
}

@property (atomic,strong) NSString* youCryptVolDir;
@property (atomic,strong) NSString* youCryptTmpDir;

/*
- (NSString*) getHomeDir;
- (BOOL) isYoucryptRunning;
- (BOOL) isYoucryptDirCreated;
- (void) createLockFile;
- (void) createHomeDir:(NSString*)path;
*/

@end
