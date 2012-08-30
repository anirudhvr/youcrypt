//
//  YoucryptConfigDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/20/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "ConfigDirectory.h"
#import "libFunctions.h"
#include "encfs-core/yc_openssl_rsaapps.h"
#include "PassphraseManager.h"
#include "AppDelegate.h"
#include <string>
#include <map>

@implementation ConfigDirectory

@synthesize youCryptVolDir;
@synthesize youCryptTmpDir;
@synthesize youCryptLogDir;
@synthesize youCryptKeyDir;
@synthesize youCryptPrivKeyFile;
@synthesize youCryptPubKeyFile;
@synthesize youCryptLockFile;
@synthesize youCryptListFile;
@synthesize firstRun;
@synthesize youcryptUserUUID;

-(id)init
{
    self = [super init];
    
    NSString *homedir = NSHomeDirectory();
    
    youCryptVolDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/volumes"];
    youCryptTmpDir = [homedir stringByAppendingPathComponent:@"/.youcrypt/tmp"];
    youCryptLogDir = [homedir stringByAppendingFormat:@"/.youcrypt/logs"];
    youCryptKeyDir = [homedir stringByAppendingFormat:@"/.youcrypt/keys"];
    youCryptPrivKeyFile = [youCryptKeyDir stringByAppendingPathComponent:@"priv.pem"];
    youCryptPubKeyFile = [youCryptKeyDir stringByAppendingPathComponent:@"pub.pem"];
    youCryptListFile = [homedir stringByAppendingPathComponent:@"/.youcrypt/dirs.plist"];
    youcryptUserUUID = [homedir stringByAppendingPathComponent:@"/.youcrypt/uuid.txt"];
    
    std::string priv([youCryptPrivKeyFile cStringUsingEncoding:NSASCIIStringEncoding]), pub([youCryptPubKeyFile cStringUsingEncoding:NSASCIIStringEncoding]);
    std::map<std::string, std::string> empty;
    cs.reset(new youcrypt::RSACredentialStorage(priv, pub, empty));
    
    return self;
}

-(BOOL)isFirstRun
{
     // Check if the most important file in the config dir exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:youCryptPrivKeyFile]) {
        firstRun = YES;
    } else {
        firstRun = NO;
    }
    return firstRun;
}

-(NSString*) checkKeys // Called after passphrase received from user
{
    string pass([[theApp.passphraseManager getPassphrase] cStringUsingEncoding:NSASCIIStringEncoding]);
    if (!cs->checkCredentials(pass))
        return @"Passphrase incorrect? (Cannot decrypt keys)";
    else
        return nil;
    
}

-(youcrypt::CredentialStorage) getCredStorage
{
    return cs;
}

-(void)firstRunSuccessful
{    
    if (![libFunctions mkdirRecursive:youCryptLogDir]) {
        DDLogVerbose(@"First run: could not create youcrypt logdir");
    } else if (![libFunctions mkdirRecursive:youCryptVolDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt vol dir");
    } else if (![libFunctions mkdirRecursive:youCryptTmpDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt Tmp dir");
    } else if (![libFunctions mkdirRecursive:youCryptKeyDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt keys dir");
    } else if ([self checkKeys] != nil) { // Will create keys if they don't exist
        DDLogError(@"Something went wrong in decrypting credentials");
    } else {
        // Create unique ID for this user for anonymous tracking
        NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        NSError *error;
        [uuid writeToFile:youcryptUserUUID atomically:YES encoding:NSASCIIStringEncoding error:&error];
        if(!error) {
            firstRun = NO;
        } else {
            DDLogVerbose(@"Could not create uuid.txt : %@",[error localizedDescription]);
        }
    }
}

-(NSString*)getLogDir
{
    return youCryptLogDir;
}
@end
