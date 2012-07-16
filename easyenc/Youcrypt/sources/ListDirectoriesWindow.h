//
//  ListDirectoriesWindow.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoucryptDirectory.h"
#import "VolumePropertiesSheetController.h"
#import "ListDirTable.h"

#define AddToolbarItemIdentifier @"Add"
#define RemoveToolbarItemIdentifier @"Remove"
#define PreferencesToolbarItemIdentifier @"Preferences"
#define ChangePassphraseToolbarIdentifier @"Change Passphrase"
#define QuitToolbarItemIdentifier @"Quit"
#define HelpToolbarItemIdentifier @"Help"

@class PassphraseSheetController;

@interface ListDirectoriesWindow : NSWindowController <NSWindowDelegate, NSDraggingDestination, NSToolbarDelegate> {
    IBOutlet ListDirTable *table;
    IBOutlet NSTextField *dirName;          // The text field at the bottom.
    IBOutlet NSImageView *backgroundImageView;

    // Toolbar
    IBOutlet NSToolbar *toolbar;
    NSArray *allowedToolbarItemKeys;
    NSMutableDictionary *allowedToolbarItemDetails;
    VolumePropertiesSheetController *volumePropsSheet;
    
    PassphraseSheetController *passphraseSheet;
        
}

@property (atomic, strong) IBOutlet ListDirTable *table;
@property (atomic, strong) IBOutlet NSImageView *backgroundImageView;

@property (nonatomic, strong) PassphraseSheetController *passphraseSheet;

- (IBAction)doEncrypt:(id)sender;
- (IBAction)doOpen:(id)sender;
- (IBAction)doProps:(id)sender;
- (IBAction)selectRow:(id)sender;
- (IBAction)addNew:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)removeFS:(id)sender;
- (IBAction)windowWillClose:(NSNotification *)notification;

- (void)setStatusToSelectedRow:(NSInteger)row;
- (void)doOpenProxy:(NSInteger)row ;

// Toolbar / UI stuff
- (IBAction)resizeWindow:(id)sender;
- (void) initToolbarItems;


- (void) showPreferencePanel;
- (void) exitApp;
- (void) showHelp;
- (void) showChangePassphraseSheet;

- (void) keyDownCallback: (int) keyCode;

@end
