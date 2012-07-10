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
        

    // Config directory
    ConfigDirectory *configDir;
    BOOL configDirBeingSynced;
    PeriodicActionTimer *timer;
    
    YoucryptService *youcryptService;
    
    FirstRunSheetController *firstRunSheetController;
    FeedbackSheetController *feedbackSheetController;
    
    // List of directories maintained by us.
    // Objects added should be (YoucryptDirectory *)
    NSMutableArray *directories;
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
- (IBAction)showEncryptWindow:(id)sender;
- (IBAction)showDecryptWindow:(id)sender path:(NSString *)path mountPoint:(NSString *)mountPath;
- (IBAction)showListDirectories:(id)sender;
- (IBAction)openFeedbackPage:(id)sender;
- (IBAction)openHelpPage:(id)sender;

-(void)encryptFolder:(NSString *)path;
-(BOOL)openEncryptedFolder:(NSString *)path;
-(void)didDecrypt:(NSString *)path;
-(void)didEncrypt:(NSString *)path;
-(void)didRestore:(NSString *)path;

-(void) removeFSAtRow:(int) row ;


- (void) showFirstRun;



// Setters and getters
@property (readonly) NSMutableArray *directories;
@property (assign) IBOutlet NSWindow *window;
@property (atomic,strong) Encrypt *encryptController;
@property (atomic,strong) Decrypt *decryptController;
@property (atomic,strong) ConfigDirectory *configDir;
@property (nonatomic,strong) ListDirectoriesWindow *listDirectories;
@property (nonatomic, strong) FirstRunSheetController *firstRunSheetController;
@property (nonatomic, strong) FeedbackSheetController *feedbackSheetController;

@end

extern AppDelegate *theApp;
extern NSWindow *_window;
