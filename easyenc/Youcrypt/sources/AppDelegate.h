//
//  AppDelegate.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RestoreController.h"
#import <boost/shared_ptr.hpp>
#import "DirectoryMap.h"
#import <map>

@class PreferenceController;
@class FileSystemsController;
@class Decrypt;
@class Encrypt;
@class ConfigDirectory;
@class YoucryptDirectory;
@class YoucryptService;
@class ListDirectoriesWindow;
@class FirstRunSheetController;
@class FeedbackSheetController;
@class PeriodicActionTimer;
@class keyDownView;
@class DDFileLogger;
@class CompressingLogFileManager;
@class TourWizard;
@class MixpanelAPI;
@class AboutController;
@class PassphraseManager;



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
    TourWizard *tourWizard;
    AboutController *aboutController;

    // Config directory
    ConfigDirectory *configDir;
    BOOL configDirBeingSynced;
    PeriodicActionTimer *timer;
    
    YoucryptService *youcryptService;
    PassphraseManager *passphraseManager;
    
    FirstRunSheetController *firstRunSheetController;
    FeedbackSheetController *feedbackSheetController;
    keyDownView *keyDown;

    // List of directories maintained by us.
    // Objects added should be (YoucryptDirectory *)
//    NSMutableArray *directories;    
    boost::shared_ptr<DirectoryMap> directories;
    
    DDFileLogger *fileLogger;
    NSString *mixpanelUUID;
    
    BOOL callFinderScript;
    
    NSMutableArray *encryptQ, *decryptQ, *restoreQ;
    long enQIndex, deQIndex, reQIndex;
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

//- (void)showFirstRunSheet;
//- (void)showFirstRun;

// Enc and Dec
- (IBAction)showListDirectories:(id)sender;
- (IBAction)openFeedbackPage:(id)sender;
- (IBAction)openHelpPage:(id)sender;
- (IBAction)showAboutWindow:(id)sender;

-(BOOL)openEncryptedFolder:(NSString *)path;
-(BOOL)doDecrypt:(YoucryptDirectory*)dir;
-(void)didDecrypt:(YoucryptDirectory *)dir;
-(void)cancelDecrypt:(YoucryptDirectory *)dir;

-(BOOL)encryptFolder:(NSString *)path;
-(BOOL)doEncrypt:(NSString *)path;
-(void)didEncrypt:(YoucryptDirectory *)dir;
-(void)cancelEncrypt:(NSString *)path;

-(void)removeFSAtRow:(long) row ;
-(void)removeFSAtPath:(NSString*) path;
-(void)didRestore:(NSString *)path;
-(void)cancelRestore:(NSString *)path;
-(BOOL)doRestore:(NSString *)path;



- (void) showTour;

-(id) unarchiveDirectoryList:(id) sender;
-(boost::shared_ptr<DirectoryMap>) getDirectories;
    

// Setters and getters
//@property (readonly) NSMutableArray *directories;
@property (assign) IBOutlet NSWindow *window;
@property (atomic,strong) Encrypt *encryptController;
@property (atomic,strong) Decrypt *decryptController;
@property (atomic,strong) ConfigDirectory *configDir;
@property (nonatomic,strong) ListDirectoriesWindow *listDirectories;
@property (nonatomic, strong) FirstRunSheetController *firstRunSheetController;
@property (nonatomic, strong) FeedbackSheetController *feedbackSheetController;
@property (nonatomic, strong) keyDownView *keyDown;
@property (nonatomic, strong) PreferenceController *preferenceController;
@property (nonatomic, strong) DDFileLogger *fileLogger;
@property (nonatomic, strong) NSMutableSet *dropboxEncryptedFolders;
@property (nonatomic, strong) TourWizard *tourWizard;
@property (nonatomic, strong) NSString *mixpanelUUID;
@property (nonatomic, strong) AboutController *aboutController;
@property (nonatomic, strong) PassphraseManager *passphraseManager;

@end

extern AppDelegate *theApp;
extern NSWindow *_window;
extern CompressingLogFileManager *logFileManager;
extern MixpanelAPI *mixpanel;
