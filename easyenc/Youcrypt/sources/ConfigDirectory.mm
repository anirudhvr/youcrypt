//
//  YoucryptConfigDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/20/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "ConfigDirectory.h"
#import "libFunctions.h"
extern "C"  {
#include "encfs-core/yc_openssl_rsaapps.h"
}
#include "PassphraseManager.h"
#include "AppDelegate.h"

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

-(void)firstRunSuccessful
{    
    if (![libFunctions mkdirRecursive:youCryptLogDir]) {
        DDLogVerbose(@"First run: could not create youcrypt logdir");
    } else if (![libFunctions mkdirRecursive:youCryptVolDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt vol dir");
    } else if (![libFunctions mkdirRecursive:youCryptTmpDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt Tmp dir");
<<<<<<< HEAD
    } else if (![libFunctions mkdirRecursive:_youCryptKeyDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt Tmp dir");
=======
    } else if (![libFunctions mkdirRecursive:youCryptKeyDir]) {
        DDLogVerbose(@"First run: could not create Youcrypt keys dir");
>>>>>>> origin/dev
    } else {
        // Do all initialization here
        
        // Create a keypair for that user
        // XXX FIXME make this more modular - wrap this in a class or something
        NSString *pp = [theApp.passphraseManager getPassphrase];
        
        if (pp == nil || pp == @"") {
            DDLogError(@"Passphrase should be set by now but isnt!");
            return;
        }
        pp = [@"pass:" stringByAppendingString:pp];
        
        char *genprivkey_argv[] = {"genpkey",
            "-out", (char*)[youCryptPrivKeyFile cStringUsingEncoding:NSASCIIStringEncoding],
            "-outform", "PEM",
            "-pass", (char*)[pp cStringUsingEncoding:NSASCIIStringEncoding],
            "-aes-256-cbc",
            "-algorithm", "RSA",
            "-pkeyopt", "rsa_keygen_bits:2048"
        };
        
        if (genpkey(sizeof(genprivkey_argv)/sizeof(genprivkey_argv[0]),
                    genprivkey_argv)) {
            DDLogError(@"RSA private key generation failed");
            return;
        }
        
        // Set mode of private key to 600
        [[NSFileManager defaultManager] setAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithShort:0600], NSFilePosixPermissions, nil] ofItemAtPath:youCryptPrivKeyFile error:nil];
        
        char *genpubkey_argv[] = {"rsa",
            "-pubout",
            "-in", (char*)[youCryptPrivKeyFile cStringUsingEncoding:NSASCIIStringEncoding],
            "-out", (char*)[youCryptPubKeyFile cStringUsingEncoding:NSASCIIStringEncoding],
            "-ycpass", (char*)[pp cStringUsingEncoding:NSASCIIStringEncoding],
        };
        
        if (rsa(sizeof(genpubkey_argv)/sizeof(genpubkey_argv[0]),
                 genpubkey_argv)) {
            DDLogError(@"RSA pubkey extraction failed");
            return;
        }
        
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
