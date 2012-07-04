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
    BOOL needsCreation;
}

@property (atomic,strong) NSString* youCryptVolDir;
@property (atomic,strong) NSString* youCryptTmpDir;
@property (atomic,strong) NSString* youCryptLogDir;
@property (nonatomic, strong) NSString *youCryptLockFile;
@property (nonatomic,strong) NSString *youCryptListFile;


/*
 - (NSString*) getHomeDir;
 - (BOOL) isYoucryptRunning;
 - (BOOL) isYoucryptDirCreated;
 - (void) createLockFile;
 - (void) createHomeDir:(NSString*)path;
 */

@end

