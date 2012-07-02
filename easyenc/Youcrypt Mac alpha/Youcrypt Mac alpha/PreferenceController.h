//
//  PreferenceController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class StartOnLogin;
@class PassphraseSheetController;

// string prefrence keys
#define YC_DROPBOXLOCATION  @"yc.dropboxfolderlocation"
#define YC_BOXLOCATION      @"yc.boxfolderlocation"
#define YC_USERREALNAME     @"yc.userrealname"
#define YC_USEREMAIL        @"yc.email"

// bool preference keys
#define YC_ENCRYPTFILENAMES @"yc.encryptfilenames"
#define YC_STARTONBOOT      @"yc.startonboot"

@interface PreferenceController : NSWindowController {
    
    // the tabview
    NSTabView *tabView;    

    // the preference keys and the preferences array
    NSArray *preferencesKeys;
    NSDictionary *defaultPreferences;
    NSMutableDictionary *preferences;
    
    // General preferences
    IBOutlet NSButton *startOnBoot;
    IBOutlet NSButton *enableFilenameEncryption;
    // Libarray to start on login
    StartOnLogin *startOnLogin;
    
    // Account preferences
    IBOutlet NSTextField *realName;
    IBOutlet NSTextField *email;
    IBOutlet NSSecureTextField *passphrase;
    IBOutlet NSSecureTextField *passphrase_verification;
    
    PassphraseSheetController *passphraseSheetController;
    IBOutlet NSButton *changePassphraseButton;
    
    // Services preferences
    IBOutlet NSButton *checkbox;
    IBOutlet NSPathControl *dropboxLocation;
    IBOutlet NSPathControl *boxLocation;
}

// changing passphrase stuff
@property (nonatomic, strong) PassphraseSheetController *passphraseSheetController;
@property (nonatomic, strong) IBOutlet NSButton *changePassphraseButton;

// public methods
- (id)getPreference:(NSString*)key;
- (void)setPreference:(NSString*)key value:(id)val;

/*
 *  Private methods
 */
// utility methods
- (void)updatePreferences:(NSDictionary*)prefs;

// General tab methods
- (IBAction)filenameEncryptionChecked:(id)sender;
- (IBAction)startOnBootChecked:(id)sender;
- (IBAction)saveGeneralPrefs:(id)sender;


// Account tab methods
- (IBAction)changePassphrase:(id)sender;
- (IBAction)saveAccountPrefs:(id)sender;


// Services tab methods
- (IBAction)chooseDropboxLocation:(id)sender;
- (IBAction)saveServicesPrefs:(id)sender;
-(NSString*) locateDropboxFolder;
-(NSString*) locateBoxFolder;
static NSArray *openFiles();

// start at login
- (NSURL *)appURL;  

@end
