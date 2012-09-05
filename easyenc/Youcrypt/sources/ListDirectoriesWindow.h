//
//  ListDirectoriesWindow.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VolumePropertiesSheetController.h"
#import "ListDirTable.h"
#import "LinkedView.h"
#import "core/YCFolder.h"
#import "yc-networking/ServerConnectionWrapper.h"


#define AddToolbarItemIdentifier @"Add"
#define RemoveToolbarItemIdentifier @"Remove"
#define PreferencesToolbarItemIdentifier @"Preferences"
#define ChangePassphraseToolbarIdentifier @"Change Passphrase"
#define QuitToolbarItemIdentifier @"Quit"
#define HelpToolbarItemIdentifier @"Help"

@class PassphraseSheetController;
@class SharingGetEmailsView;

@interface ListDirectoriesWindow : NSWindowController <NSWindowDelegate, NSDraggingDestination, NSToolbarDelegate> {
    IBOutlet ListDirTable *table;
    IBOutlet NSTextField *dirName;          // The text field at the bottom.
    IBOutlet NSTextField *statusLabel;
    IBOutlet NSImageView *backgroundImageView;
    IBOutlet NSProgressIndicator *progressIndicator; 

    // Toolbar
    IBOutlet NSToolbar *toolbar;
    NSArray *allowedToolbarItemKeys;
    NSMutableDictionary *allowedToolbarItemDetails;
    VolumePropertiesSheetController *volumePropsSheet;
    
    PassphraseSheetController *passphraseSheet;
    
    IBOutlet SharingGetEmailsView *sharingGetEmailsView;
    IBOutlet NSPopover *sharingPopover;
    
    // For server connection
    boost::shared_ptr<youcrypt::ServerConnectionWrapper> serverConnectionWrapper;
        
}

@property (atomic, strong) IBOutlet ListDirTable *table;
@property (atomic, strong) IBOutlet NSImageView *backgroundImageView;
@property (atomic, strong) IBOutlet NSTextField *statusLabel;
@property (atomic, strong) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, strong) PassphraseSheetController *passphraseSheet;
@property(nonatomic, strong) SharingGetEmailsView *sharingGetEmailsView;
@property(nonatomic, strong) NSPopover *sharingPopover;

- (IBAction)doEncrypt:(id)sender;
- (IBAction)doOpen:(id)sender;
- (IBAction)doProps:(id)sender;
- (IBAction)selectRow:(id)sender;
- (IBAction)addNew:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction) shareFolder:(id) sender;
- (BOOL) performShare:(NSString*)email message:(NSString*)msg;
- (IBAction)removeFS:(id)sender;

- (void)setStatusToSelectedRow:(NSInteger)row;
- (void)doOpenProxy:(NSInteger)row ;
- (int)closeMountedFolder:(Folder) dir;
- (void)getPassphraseFromUser:(id) sender;

// Toolbar / UI stuff
- (IBAction)resizeWindow:(id)sender;
- (void) initToolbarItems;


- (void) showPreferencePanel;
- (void) exitApp;
- (void) showHelp;
- (void) showChangePassphraseSheet;

- (void) keyDownCallback: (int) keyCode;

@end
