//
//  ListDirectoriesWindow.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListDirectoriesWindow.h"
#import "AppDelegate.h"

@implementation ListDirectoriesWindow

@synthesize table;

- (id)init
{
    if (![super initWithWindowNibName:@"ListDirectoriesWindow"])
        return nil;
    
    allowedToolbarItemKeys = [[NSArray alloc] initWithObjects:AddToolbarItemIdentifier, RemoveToolbarItemIdentifier, PreferencesToolbarItemIdentifier, QuitToolbarItemIdentifier, HelpToolbarItemIdentifier, nil];
    allowedToolbarItemDetails = [NSMutableDictionary dictionary];
    
    volumePropsSheet = [[VolumePropertiesSheetController alloc] init];
    return self;
    
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {        
    }    
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.    
}

- (void) handleDoubleClick:(id)sender
{
    if (dirName != nil)
        NSLog(@"Doubleclicked %@", [dirName stringValue]);
    [self doOpen:table];
}

- (void)awakeFromNib {
    [table setDataSource:theApp];
    [table setDelegate:theApp];

    [table registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    [table setDoubleAction:@selector(handleDoubleClick:)];
       
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"ListDirectoriesToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:YES]; 
       
    [self initToolbarItems];
    
    [self.window setToolbar:toolbar];

}

- (IBAction)doEncrypt:(id)sender {
}

- (IBAction)doOpen:(id)sender {
    if ([table clickedRow] < [theApp.directories count]) {
        YoucryptDirectory *dir = [theApp.directories objectAtIndex:[table clickedRow]];
        [theApp openEncryptedFolder:[dir path]];

    }
}

- (IBAction)doProps:(id)sender {
    
    if ([table clickedRow] < [theApp.directories count]) {
        YoucryptDirectory *dir = [theApp.directories objectAtIndex:[table clickedRow]];
        volumePropsSheet.sp = dir.path;
        volumePropsSheet.mp = dir.mountedPath;
        volumePropsSheet.stat = ((dir.status == YoucryptDirectoryStatusMounted) ? @"Mounted" : @"Not Mounted");
        [volumePropsSheet beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
            if (returnCode == 0) {
                NSLog(@"sheet returned success");
            }
        }];
    }
    
    
   
}

- (IBAction)selectRow:(id)sender {
   if ([sender clickedRow] < [theApp.directories count]) {
        YoucryptDirectory *dir = [theApp.directories objectAtIndex:[sender clickedRow]];
        [dirName setStringValue:dir.path];
    }
}

- (IBAction)addNew:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // NO files, YES directories and knock yourself out[TM] with as many as you want
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        for( int i = 0; i < [files count]; i++ )
            [theApp encryptFolder:[files objectAtIndex:i]];
        [table reloadData];
    }

}

- (IBAction)removeFS:(id)sender {
    NSInteger row = [table selectedRow];
    if (row < [theApp.directories count] && row != -1) {
        YoucryptDirectory *dir = [theApp.directories objectAtIndex:row];
        if (dir.status == YoucryptDirectoryStatusError || 
            dir.status == YoucryptDirectoryStatusNotFound) {
            [table beginUpdates];
            [table removeRowsAtIndexes:[[NSIndexSet alloc] initWithIndex:row] withAnimation:NSTableViewAnimationSlideUp];
            [table endUpdates];
            [theApp.directories removeObjectAtIndex:row];
        } else if (dir.status == YoucryptDirectoryStatusMounted) {
            [NSAlert alertWithMessageText:@"Cannot remove a mounted directory" defaultButton:@"Okay" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:@""]; 
        } else if (dir.status == YoucryptDirectoryStatusUnmounted) {
             [NSAlert alertWithMessageText:@"Cannot even remove a directory that is unmounted" defaultButton:@"Okay" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:@""]; 
        }
    }
    [table reloadData];
}
 


/***
 ***
 
 TOOLBAR FUNCTIONS 
 
 ***
 ***/

- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
                                       label:(NSString *)label
                                 paleteLabel:(NSString *)paletteLabel
                                     toolTip:(NSString *)toolTip
                                      target:(id)target
                                 itemContent:(id)imageOrView
                                      action:(SEL)action
{
    // here we create the NSToolbarItem and setup its attributes in line with the parameters
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    [item setTarget:target];
    [item setAction:action];
    
    if([imageOrView isKindOfClass:[NSImage class]]){
        [item setImage:imageOrView];
    } 
    else if ([imageOrView isKindOfClass:[NSView class]]){
        [item setView:imageOrView];
    }
    else {
        assert(!"Invalid itemContent: object");
    }
    return item;
}



- (void)toolbarWillAddItem:(NSNotification *)notif
{
    NSToolbarItem *addedItem = [[notif userInfo] objectForKey:@"item"];
    
    // Is this the printing toolbar item?  If so, then we want to redirect it's action to ourselves
    // so we can handle the printing properly; hence, we give it a new target.
    //
    if ([[addedItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier])
    {
        [addedItem setToolTip:@"Print your document"];
        [addedItem setTarget:self];
    }
}  

- (IBAction)resizeWindow:(id)sender
{
    NSRect myRect = NSMakeRect(1000,200,300,400);
    [self.window setFrame:myRect display:YES animate:YES];
    
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
     itemForItemIdentifier:(NSString *)itemIdentifier 
 willBeInsertedIntoToolbar:(BOOL)flag

{
    NSToolbarItem *toolbarItem = nil;
    
    // We create and autorelease a new NSToolbarItem, and then go through the process of setting up its
    // attributes from the master toolbar item matching that identifier in our dictionary of items.
    
    if ([allowedToolbarItemDetails objectForKey:itemIdentifier] != nil) {
        
    toolbarItem = [self toolbarItemWithIdentifier:itemIdentifier
                                               label:[[allowedToolbarItemDetails objectForKey:itemIdentifier] objectForKey:@"label"]
                                         paleteLabel:[[allowedToolbarItemDetails objectForKey:itemIdentifier] objectForKey:@"palettelabel"]
                                              toolTip:[[allowedToolbarItemDetails objectForKey:itemIdentifier] objectForKey:@"tooltip"]   
                                               target:[[allowedToolbarItemDetails objectForKey:itemIdentifier] objectForKey:@"target"]   
                                         itemContent:[NSImage imageNamed:[[allowedToolbarItemDetails objectForKey:itemIdentifier] objectForKey:@"image"]]
                                              action:NSSelectorFromString([[allowedToolbarItemDetails objectForKey:itemIdentifier] objectForKey:@"selector"])
                      ]; 
    }
    
    return toolbarItem;
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for the default
// set of toolbar items.  It can also be called by the customization palette to display the default toolbar.  
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:AddToolbarItemIdentifier,NSToolbarSeparatorItemIdentifier,
            RemoveToolbarItemIdentifier, NSToolbarSeparatorItemIdentifier,
            PreferencesToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
            HelpToolbarItemIdentifier, NSToolbarSpaceItemIdentifier,
            QuitToolbarItemIdentifier, nil];
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for all allowed
// toolbar items in this toolbar.  Any not listed here will not be available in the customization palette.
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:AddToolbarItemIdentifier,NSToolbarSeparatorItemIdentifier,
            RemoveToolbarItemIdentifier, NSToolbarSeparatorItemIdentifier,
            PreferencesToolbarItemIdentifier, NSToolbarSpaceItemIdentifier,
            HelpToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
            QuitToolbarItemIdentifier, nil];
}


- (void) initToolbarItems
{
    
    if (allowedToolbarItemDetails == nil || allowedToolbarItemKeys == nil) return;
    
    
    
    NSArray *toolbarItemKeys = [NSArray arrayWithObjects:
                                @"label", 
                                @"palettelabel", 
                                @"tooltip", 
                                @"target", 
                                @"image", 
                                @"selector", 
                                nil];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Add" /* label */, 
                                                                              @"Add" /* palletelabel */,
                                                                              @"Add Folder" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Add.png" /* image file */,
                                                                              NSStringFromSelector(@selector(addNew:)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:0]];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Remove" /* label */, 
                                                                              @"Remove" /* palletelabel */,
                                                                              @"Remove Folder" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Remove.png" /* image file */,
                                                                              NSStringFromSelector(@selector(removeFS:)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:1]];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Preferences" /* label */, 
                                                                              @"Preferences" /* palletelabel */,
                                                                              @"Show Preferences" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Preferences.png" /* image file */,
                                                                              NSStringFromSelector(@selector(showPreferencePanel)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:2]];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Exit" /* label */, 
                                                                              @"Exit" /* palletelabel */,
                                                                              @"Exit Youcrypt" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Exit.png" /* image file */,
                                                                              NSStringFromSelector(@selector(exitApp)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:3]];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Help" /* label */, 
                                                                              @"Help" /* palletelabel */,
                                                                              @"Find Help" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Help.png" /* image file */,
                                                                              NSStringFromSelector(@selector(showHelp)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:4]];
}

- (void)showPreferencePanel
{
        NSLog(@"Called showPreferences");
    [theApp showPreferencePanel:theApp];
}

- (void) exitApp 
{
        NSLog(@"Called terminate");
    [theApp terminateApp:self];
}
- (void) showHelp 
{
    NSLog(@"Called showHelp");
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://youcrypt.com"]];
}


@end
