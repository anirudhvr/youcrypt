//
//  AppDelegate.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferenceController;
@class FileSystemsController;
@class Decrypt;
@class Encrypt;
@class ConfigDirectory;
@class YoucryptService;
@class ListDirectoriesWindow;

@interface AppDelegate : NSObject <NSToolbarDelegate> { // changed from NSApplicationDelegate
    
    // Status Bar for Agent
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    
    // Controller for ListDirectoriesWindow
    ListDirectoriesWindow *listDirectories;

    // For preferences
    PreferenceController *preferenceController;
    
    //Encrypt and Decrypt
    Decrypt *decryptController;
    Encrypt  *encryptController;
    
    // Array of FileSystems
    NSMutableArray *filesystems;
    
    // Proxies - to be implemented
    FileSystemsController *fc;

    // Toolbar
    IBOutlet NSToolbar *toolbar;

    // Config directory
    ConfigDirectory *configDir;
    
    YoucryptService *youcryptService;

}

// Built in methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)awakeFromNib;
- (IBAction)windowShouldClose:(id)sender;

// Implemented
- (IBAction)showMainApp:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)terminateApp:(id)sender;
- (void)showFirstRunSheet;

// Enc and Dec
- (IBAction)showEncryptWindow:(id)sender;
- (IBAction)showDecryptWindow:(id)sender;
- (IBAction)showListDirectories:(id)sender;

-(void)setFilesystems:(NSMutableArray*)f;
- (IBAction)resizeWindow:(id)sender;

// Setters and getters
@property (assign) IBOutlet NSWindow *window;
@property (atomic,strong) Encrypt *encryptController;
@property (atomic,strong) Decrypt *decryptController;
@property (atomic,strong) ConfigDirectory *configDir;
@property (nonatomic,strong) ListDirectoriesWindow *listDirectories;


@end
