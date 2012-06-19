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

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    // Status Bar for Agent
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;

    // For preferences
    PreferenceController *preferenceController;
    
    // Array of FileSystems
    NSMutableArray *filesystems;
    
    // Proxies - to be implemented
    FileSystemsController *fc;

}

@property (assign) IBOutlet NSWindow *window;

// Built in methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)awakeFromNib;
- (IBAction)windowShouldClose:(id)sender;

// Implemented
- (IBAction)showMainApp:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)terminateApp:(id)sender;

-(void)setFilesystems:(NSMutableArray*)f;

// to implement
- (IBAction)launchAgent:(id)sender;

@end
