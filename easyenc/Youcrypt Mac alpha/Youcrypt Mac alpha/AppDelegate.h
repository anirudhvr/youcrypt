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
@class YoucryptConfigDirectory;
@class YoucryptService;
@class ListDirectoriesWindow;

@interface AppDelegate : NSObject <NSTableViewDataSource> { // changed from NSApplicationDelegate
    
    // Status Bar for Agent
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    
    // Controllers for various windows
    ListDirectoriesWindow *listDirectories;
    PreferenceController *preferenceController;
    Decrypt *decryptController;
    Encrypt  *encryptController;
        

    // Config directory
    YoucryptConfigDirectory *configDir;    
    YoucryptService *youcryptService;
    
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
- (IBAction)showEncryptWindow:(id)sender;
- (IBAction)showDecryptWindow:(id)sender;
- (IBAction)showListDirectories:(id)sender;


-(void)encryptFolder:(NSString *)path;
-(BOOL)openEncryptedFolder:(NSString *)path;


// Setters and getters
@property (readonly) NSMutableArray *directories;
@property (assign) IBOutlet NSWindow *window;
@property (atomic,strong) Encrypt *encryptController;
@property (atomic,strong) Decrypt *decryptController;
@property (atomic,strong) YoucryptConfigDirectory *configDir;
@property (nonatomic,strong) ListDirectoriesWindow *listDirectories;


@end

extern AppDelegate *theApp;
extern NSWindow *_window;
