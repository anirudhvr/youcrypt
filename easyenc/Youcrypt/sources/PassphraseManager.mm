//
//  PassphraseManager.m
//  Youcrypt
//
//  Created by avr on 8/1/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "PassphraseManager.h"
#import "libFunctions.h"
#import "contrib/SSKeychain/SSKeychain.h"
#import "PreferenceController.h"
#import "AppDelegate.h"
#import "contrib/passwdqc/passwdqc.h"
#import "RSACredentialManager.h"


@implementation PassphraseManager

@synthesize passPhrase;
@synthesize saveInKeychain;
@synthesize serviceName;

@synthesize email;
@synthesize message;
@synthesize pass;
@synthesize closeButton;


- (id)initWithPrefController:(PreferenceController*)pref
              saveInKeychain:(BOOL)save {
    self = [super initWithWindowNibName:@"AskPassphrase"];
    if (!self)
        return nil;
    
    saveInKeychain = save;
    prefC = pref;
    passPhrase = @"";
    
    return self;
}


-(void)awakeFromNib {
    NSString *e = nil;
    [email becomeFirstResponder];
    if (prefC && (e = [prefC getPreference:(MacUISettings::MacPreferenceKeys::yc_useremail)]) && (e != nil))
        [email setStringValue:e];
    else
        [email setStringValue:@""];
    
    //[pass setStringValue:@"" ];
    
    //[closeButton setTarget:self];
    //[closeButton setAction:@selector(closeButtonClicked:)];
}

-(IBAction)closeButtonClicked:(id) sender
{
//    NSLog(@"close button clicked");
}

-(IBAction)goClicked:(id) sender {
    if ([[pass stringValue] isNotEqualTo:@""] && ([[pass stringValue] length] >= 4)) {
        passPhrase = [pass stringValue];
        NSString *errmsgBuf = nil;
        
        if ([theApp setupCM:passPhrase createIfNotFound:NO createAccount:NO pushKeys:NO]) {
            [message setStringValue:@""];
        } else {
            [message setStringValue:@"Cannot unlock credentials - wrong passprhase?"];
            passPhrase = @"";
            return;
        }
    } else {
        [message setStringValue:@"Passphrase empty or too short"];
        return;
    }
    if (saveInKeychain)
        [self savePassphraseToKeychain];
    
    [NSApp endSheet:self.window];
    [self.window setIsVisible:NO];
    [self.window close];
}

- (BOOL)setPassphrase:(NSString*) passphrase
                error:(NSError**)err
{
    BOOL ret = YES;
    NSMutableDictionary* errdetails = [NSMutableDictionary dictionary];
    
    ////////////////////////////////////////
    //// Re-enable this for a real release
    ////////////////////////////////////////
//    char *bad_pass_reason = NULL;
//    if (yc_check_pass([passphrase cStringUsingEncoding:NSASCIIStringEncoding], &bad_pass_reason)) {
//        [errdetails setValue:[NSString stringWithFormat:@"%s", bad_pass_reason] forKey:NSLocalizedDescriptionKey];
//        // populate the error object with the details
//        *err = [NSError errorWithDomain:YC_ERRORDOMAIN code:200 userInfo:errdetails];
//        if(bad_pass_reason) free(bad_pass_reason);
//        return NO;
//    }
    
    if ([passphrase length] < 8) {
        [errdetails setValue:@"Please enter a password more than 8 characters long" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *err = [NSError errorWithDomain:YC_ERRORDOMAIN code:200 userInfo:errdetails];
        return NO;
    }
    
    passPhrase = passphrase;
    if (saveInKeychain)
        ret = [self savePassphraseToKeychain];
    
    return ret;
}

- (void)getPassphraseFromUser
{
    [NSApp runModalForWindow:[self window]];
}

- (NSString*)getPassphrase
{
    if (passPhrase == nil || [passPhrase isEqualToString:@""]) {
        DDLogVerbose(@"Passphrase nil, checking Keychain");
        if (saveInKeychain) {
            NSError *error = nil;
            NSString *passphraseFromKeychain = [SSKeychain passwordForService:YC_KEYCHAIN_SERVICENAME account:NSUserName() error:&error];
            
            if (error) {
                DDLogInfo(@"PassphraseManager:getPassphrase: Did not get passphrase from Keychain");
                return nil;
            } else {
                passPhrase = passphraseFromKeychain;
            }
        }
    }
    
    return passPhrase;
}

- (BOOL)savePassphraseToKeychain {
    NSError *error = nil;
    if ([passPhrase isEqualToString:@""]) {
        DDLogInfo(@"savePassphraseToKeychain called with empty passphrase");
        return NO;
    }
    
    [SSKeychain setPassword:passPhrase forService:YC_KEYCHAIN_SERVICENAME account:NSUserName() error:&error];
    
    if (error) {
        DDLogInfo(@"libFunctions:registerWithKeychain: Register Keychain Error: %@",[error localizedDescription]);
        return NO;
    }
    
    return YES;
}

- (BOOL)deletePassphraseFromKeychain {
    NSError *err = nil;
    BOOL ret = [SSKeychain deletePasswordForService:YC_KEYCHAIN_SERVICENAME account:NSUserName() error:&err];
    if (!ret)
        DDLogInfo(@"Error deleting password from keychain: %@", [err localizedDescription]);
    return ret;
    
}

- (BOOL)changePassphrase:(NSString*)newPassphrase
                 oldPass:(NSString*)oldPassphrase {
    if ([passPhrase isEqualTo:@""]) {
        DDLogInfo(@"PassPhrase is empty; set with setPassPhrase");
        return NO;
    }
        
    if ([passPhrase isEqualToString:oldPassphrase]) {
        passPhrase = newPassphrase;
        BOOL ret = YES;
        if (saveInKeychain)
            ret = [self savePassphraseToKeychain];
        return ret;
    } else {
        DDLogInfo(@"Stored passPhrase does not match provided passphrase");
        return NO;
    }
}

- (IBAction)IdRatherQuitThanEnterAPassword:(id)sender
{
    [theApp terminateApp:self];
}

@end
