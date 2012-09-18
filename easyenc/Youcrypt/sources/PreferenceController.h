//
//  PreferenceController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoxFSA.h"
#import "XMLDictionary.h"
#import <string>

@class StartOnLogin;
@class PassphraseSheetController;
@class GmailSheetController;

@interface PreferenceController : NSWindowController <NSAlertDelegate> {
    
    // the tabview
    IBOutlet NSTabView *tabView;    

    // General Preference Tab buttons / controls
    IBOutlet NSButton *startOnBoot;
    IBOutlet NSButton *enableFilenameEncryption;
    IBOutlet NSButton *allowAnonymousUsageStatistics;
    IBOutlet NSTextField *idleTime;
    
    // Account preferences
    IBOutlet NSTextField *realName;
    IBOutlet NSTextField *email;
    IBOutlet NSSecureTextField *passphrase;
    IBOutlet NSSecureTextField *passphrase_verification;
    IBOutlet NSButton *changePassphraseButton;
    
    // Services preferences
    IBOutlet NSButton *linkBox;
    IBOutlet NSTextField *boxLinkStatus;
    IBOutlet NSPathControl *dropboxLocation;
    IBOutlet NSPathControl *boxLocation;
    IBOutlet NSButton *linkGmail;
    IBOutlet NSImageView *dbIcon;
    IBOutlet NSImageView *boxIcon;
    
    // Libarray to start on login
    StartOnLogin *startOnLogin;
    BoxFSA *boxClient;
    GmailSheetController *gmailSheetController;
    PassphraseSheetController *passphraseSheetController;
}

// changing passphrase stuff
@property (nonatomic, strong) PassphraseSheetController *passphraseSheetController;
@property (nonatomic, strong) GmailSheetController *gmailSheetController;

@property (nonatomic, strong) IBOutlet NSButton *changePassphraseButton;
@property (nonatomic, strong) BoxFSA *boxClient;

// public methods
- (NSString*)getPreferenceFromNSString:(NSString*)key;
- (NSString*)getPreference:(std::string)key;
- (void)setPreference:(std::string)key value:(NSString*)val;
- (void)setPreferenceFromNSString:(NSString*)key value:(NSString*)val;

/*
 *  Private methods
 */
// utility methods

// General tab methods
- (IBAction)filenameEncryptionChecked:(id)sender;
- (IBAction)startOnBootChecked:(id)sender;
- (IBAction)allowAnonymousUsageStatisticsChecked:(id)sender;
- (IBAction)idleTimeChanged:(id)sender;

- (void) savePreferences;

// Account tab methods
- (IBAction)changePassphrase:(id)sender;

// Services tab methods
-(NSString*) locateBoxFolder;

- (IBAction)chooseDBLocation:(id)sender;

- (IBAction)linkBoxAccount:(id)sender;
-(void)boxAuthDone:(NSAlert *)alert returnCode:(NSInteger)returnCode;
-(NSString*)locateBoxFolder;

- (IBAction)chooseBoxLocation:(id)sender;

-(void)refreshGmailLinkStatus:(BOOL)linked;
- (IBAction)linkGmailAccount:(id)sender;

- (void) sendEmail;

// start at login
- (NSURL *)appURL;  
    

@end
