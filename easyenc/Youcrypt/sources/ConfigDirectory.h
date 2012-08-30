//
//  YoucryptConfigDirectory.h
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/20/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <boost/shared_ptr.hpp>
#include "encfs-core/Credentials.h"
#include "encfs-core/RSACredentials.h"

#define YoucryptFolderName @".youcrypt"

@interface ConfigDirectory : NSObject {
    youcrypt::CredentialStorage cs;
}

@property (atomic,strong) NSString* youCryptVolDir;
@property (atomic,strong) NSString* youCryptTmpDir;
@property (atomic,strong) NSString* youCryptLogDir;
@property (atomic,strong) NSString* youCryptKeyDir;

@property (atomic,strong) NSString* youCryptPrivKeyFile;
@property (atomic,strong) NSString* youCryptPubKeyFile;

@property (nonatomic, strong) NSString *youCryptLockFile;
@property (nonatomic,strong) NSString *youCryptListFile;
@property (nonatomic) BOOL firstRun;
@property (nonatomic, strong) NSString *youcryptUserUUID;

-(BOOL)isFirstRun;
-(void)firstRunSuccessful;
-(NSString*) checkKeys; // Called after passphrase received from user
-(youcrypt::CredentialStorage) getCredStorage;


/*
 - (NSString*) getHomeDir;
 - (BOOL) isYoucryptRunning;
 - (BOOL) isYoucryptDirCreated;
 - (void) createLockFile;
 - (void) createHomeDir:(NSString*)path;
 */

@end

