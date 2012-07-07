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

@class StartOnLogin;
@class PassphraseSheetController;
@class GmailSheetController;
@class FirstRunSheetController;

// string prefrence keys
#define YC_DROPBOXLOCATION  @"yc.dropboxfolderlocation"
#define YC_BOXLOCATION      @"yc.boxfolderlocation"
#define YC_USERREALNAME     @"yc.userrealname"
#define YC_USEREMAIL        @"yc.email"

// bool preference keys
#define YC_ENCRYPTFILENAMES @"yc.encryptfilenames"
#define YC_STARTONBOOT      @"yc.startonboot"
#define YC_GMAILUSERNAME    @"yc.gmailusername"
#define YC_BOXSTATUS        @"yc.boxstatus"

@interface PreferenceController : NSWindowController <NSAlertDelegate> {
    
    // the tabview
    IBOutlet NSTabView *tabView;    

    // the preference keys and the preferences array
    NSArray *preferencesKeys;
    NSMutableDictionary *defaultPreferences;
    NSMutableDictionary *preferences;
    
    // General preferences
    IBOutlet NSButton *startOnBoot;
    IBOutlet NSButton *enableFilenameEncryption;
    // Libarray to start on login
    StartOnLogin *startOnLogin;
    
    // Account preferences
    IBOutlet NSButton *linkBox;
    IBOutlet NSTextField *boxLinkStatus; 
    BoxFSA *boxClient;
    IBOutlet NSTextField *realName;
    IBOutlet NSTextField *email;
    IBOutlet NSSecureTextField *passphrase;
    IBOutlet NSSecureTextField *passphrase_verification;
    
    PassphraseSheetController *passphraseSheetController;
    IBOutlet NSButton *changePassphraseButton;
    
    GmailSheetController *gmailSheetController;
    FirstRunSheetController *firstRunSheetController;
    
    // Services preferences
    IBOutlet NSPathControl *dropboxLocation;
    IBOutlet NSPathControl *boxLocation;
    
    IBOutlet NSButton *linkGmail;
    IBOutlet NSImageView *dbIcon;
    IBOutlet NSImageView *boxIcon;
}

// changing passphrase stuff
@property (nonatomic, strong) PassphraseSheetController *passphraseSheetController;
@property (nonatomic, strong) GmailSheetController *gmailSheetController;
@property (nonatomic, strong) FirstRunSheetController *firstRunSheetController;

@property (nonatomic, strong) IBOutlet NSButton *changePassphraseButton;

// public methods
- (id)getPreference:(NSString*)key;
- (void)setPreference:(NSString*)key value:(id)val;
- (void)removePreference:(NSString*)key;

/*
 *  Private methods
 */
// utility methods
- (void)updatePreferences:(NSDictionary*)prefs;

// General tab methods
- (IBAction)filenameEncryptionChecked:(id)sender;
- (IBAction)startOnBootChecked:(id)sender;
- (IBAction)saveGeneralPrefs:(id)sender;

- (void) savePreferences;

// Account tab methods
- (IBAction)changePassphrase:(id)sender;
- (IBAction)saveAccountPrefs:(id)sender;


// Services tab methods
- (IBAction)saveServicesPrefs:(id)sender;
-(NSString*) locateDropboxFolder;
-(NSString*) locateBoxFolder;
static NSArray *openFiles();

@property (nonatomic, strong) BoxFSA *boxClient;

- (IBAction)chooseDBLocation:(id)sender;

- (IBAction)linkBoxAccount:(id)sender;
-(void)boxAuthDone:(NSAlert *)alert returnCode:(NSInteger)returnCode;
-(NSString*)locateBoxFolder;

- (IBAction)chooseBoxLocation:(id)sender;

-(void)refreshGmailLinkStatus:(BOOL)linked;
- (IBAction)linkGmailAccount:(id)sender;

- (void) sendEmail;
- (void) showFirstRun;

// start at login
- (NSURL *)appURL;  
    

@end
