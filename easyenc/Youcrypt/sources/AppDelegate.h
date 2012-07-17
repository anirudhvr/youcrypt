//
//  AppDelegate.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RestoreController.h"

@class PreferenceController;
@class FileSystemsController;
@class Decrypt;
@class Encrypt;
@class ConfigDirectory;
@class YoucryptService;
@class ListDirectoriesWindow;
@class FirstRunSheetController;
@class FeedbackSheetController;
@class PeriodicActionTimer;
@class keyDownView;
@class TourController;
@class DDFileLogger;
@class CompressingLogFileManager;
@class TourWizard;
@class MixpanelAPI;
@class AboutController;

@interface AppDelegate : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSApplicationDelegate> { // changed from NSApplicationDelegate
    
    // Status Bar for Agent
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    
    // Controllers for various windows
    ListDirectoriesWindow *listDirectories;
    PreferenceController *preferenceController;
    Decrypt *decryptController;
    Encrypt  *encryptController;
    RestoreController *restoreController;
    TourController *tourController;
    TourWizard *tourWizard;
    AboutController *aboutController;

    // Config directory
    ConfigDirectory *configDir;
    BOOL configDirBeingSynced;
    PeriodicActionTimer *timer;
    
    YoucryptService *youcryptService;
    
    FirstRunSheetController *firstRunSheetController;
    FeedbackSheetController *feedbackSheetController;
    keyDownView *keyDown;

    // List of directories maintained by us.
    // Objects added should be (YoucryptDirectory *)
    NSMutableArray *directories;
    NSMutableSet *dropboxEncryptedFolders;
    
    DDFileLogger *fileLogger;
    NSString *mixpanelUUID;
    
    BOOL callFinderScript;
}



// Built in methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)awakeFromNib;
- (IBAction)windowShouldClose:(id)sender;

// Window Related Stuff:  show / close app, etc.
- (IBAction)showMainApp:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)terminateApp:(id)sender;

- (IBAction)openFeedbackPage:(id)sender;

- (void)showFirstRunSheet;

// Enc and Dec
- (IBAction)showEncryptWindow:(id)sender path:(NSString *)path;
- (IBAction)showDecryptWindow:(id)sender path:(NSString *)path mountPoint:(NSString *)mountPath;
- (IBAction)showListDirectories:(id)sender;
- (IBAction)openFeedbackPage:(id)sender;
- (IBAction)openHelpPage:(id)sender;
- (IBAction)showAboutWindow:(id)sender;

-(void)encryptFolder:(NSString *)path;
-(BOOL)openEncryptedFolder:(NSString *)path;
-(void)didDecrypt:(NSString *)path;
-(void)didEncrypt:(NSString *)path;
-(void)didRestore:(NSString *)path;

-(void) cancelDecrypt:(NSString *)path;
-(void) cancelRestore:(NSString *)path;



-(void) removeFSAtRow:(int) row ;


- (void) showFirstRun;
- (void) showTour;

- (void) encryptDropboxFolders;
- (void) encryptFolders: (NSArray*) folders;

// Setters and getters
@property (readonly) NSMutableArray *directories;
@property (assign) IBOutlet NSWindow *window;
@property (atomic,strong) Encrypt *encryptController;
@property (atomic,strong) Decrypt *decryptController;
@property (atomic,strong) ConfigDirectory *configDir;
@property (nonatomic,strong) ListDirectoriesWindow *listDirectories;
@property (nonatomic, strong) FirstRunSheetController *firstRunSheetController;
@property (nonatomic, strong) FeedbackSheetController *feedbackSheetController;
@property (nonatomic, strong) keyDownView *keyDown;
@property (nonatomic, strong) PreferenceController *preferenceController;
@property (nonatomic, strong) TourController *tourController;
@property (nonatomic, strong) DDFileLogger *fileLogger;
@property (nonatomic, strong) NSMutableSet *dropboxEncryptedFolders;
@property (nonatomic, strong) TourWizard *tourWizard;
@property (nonatomic, strong) NSString *mixpanelUUID;
@property (nonatomic, strong) AboutController *aboutController;

@end

extern AppDelegate *theApp;
extern NSWindow *_window;
extern CompressingLogFileManager *logFileManager;
extern MixpanelAPI *mixpanel;
