//
//  ListDirectoriesWindow.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListDirectoriesWindow.h"
#import "core/Settings.h"
#import "ListDirTable.h"
#import "PassphraseSheetController.h"
#import "libFunctions.h"
#import "Contrib/Mixpanel_fpotter.github.com/MPLib/MixpanelAPI.h"
#import "PreferenceController.h"
#import "SharingGetEmailsView.h"

#import <boost/shared_ptr.hpp>
#import <boost/scoped_ptr.hpp>

#import "core/CredentialsManager.h"
#import "yc-networking/UserAccount.h"
#import "yc-networking/Key.h"
#import "yc-networking/ServerConnectionWrapper.h"
#include "encfs-core/Credentials.h"
#include "encfs-core/PassphraseCredentials.h"
#include "encfs-core/RSACredentials.h"
#import "AppDelegate.h"

#import <iostream>
#import <cstdio>

namespace yc = youcrypt;

@implementation ListDirectoriesWindow

@synthesize table;
@synthesize passphraseSheet;
@synthesize backgroundImageView;
@synthesize progressIndicator;
@synthesize statusLabel;
@synthesize sharingGetEmailsView;
@synthesize sharingPopover;

- (id)init
{
    if (!(self = [super initWithWindowNibName:@"ListDirectoriesWindow"]))
        return nil;

    allowedToolbarItemKeys = [[NSArray alloc] initWithObjects:AddToolbarItemIdentifier, RemoveToolbarItemIdentifier, PreferencesToolbarItemIdentifier, ChangePassphraseToolbarIdentifier, QuitToolbarItemIdentifier, HelpToolbarItemIdentifier, nil];
    allowedToolbarItemDetails = [NSMutableDictionary dictionary];
    
    volumePropsSheet = [[VolumePropertiesSheetController alloc] init];
    passphraseSheet = [[PassphraseSheetController alloc] init];
    
    
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
//    if (dirName != nil)
//        NSLog(@"Doubleclicked %@", [dirName stringValue]);
    [self doOpen:table];
}

- (void) keyDownCallback: (int) keyCode
{
//    NSLog(@"KEYDOWN !!! : %d",keyCode);
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
    [table setListDir:self];
    [[self window] makeFirstResponder:table];
    
    [table setImageViewUnderTable:backgroundImageView];
    [table setUpTrackingArea];
    
    [progressIndicator setHidden:YES];
    
}

- (IBAction)doEncrypt:(id)sender {
}

- (IBAction)doOpen:(id)sender {
    [self doOpenProxy:[table clickedRow]];
}

- (void)doOpenProxy:(NSInteger) row {
    Folder f = getDirectories()[row];
    if (f) {
        [theApp openEncryptedFolder:nsstrFromCpp(f->rootPath())];
    }
}

- (IBAction)doProps:(id)sender {
    Folder dir = getDirectories()[[table selectedRow]];
    if (dir) {
        [theApp openEncryptedFolder:nsstrFromCpp(dir->rootPath())];
        volumePropsSheet.sp = nsstrFromCpp(dir->rootPath());
        volumePropsSheet.mp = nsstrFromCpp(dir->mountedPath());
        volumePropsSheet.stat = nsstrFromCpp(dir->stringStatus());
        if (dir->currStatus() == YoucryptDirectoryStatusMounted) {
            volumePropsSheet.mntdate = nsstrFromCpp(dir->mountedDate());
            volumePropsSheet.openedby = NSFullUserName();
        }
        [volumePropsSheet beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
            if (returnCode == 0) {
                DDLogVerbose(@"sheet returned success");
            }
        }];
    }
}

- (IBAction)selectRow:(id)sender {    
    Folder dir = getDirectories()[[sender clickedRow]];
    if (dir) {
        [self setStatusToSelectedRow:[sender clickedRow]];
    }
}

- (void)setStatusToSelectedRow:(NSInteger)row {
    Folder dir = getDirectories()[row];
    if (dir) {
        NSString *pth = nsstrFromCpp(dir->rootPath());
        [dirName setStringValue:[NSString stringWithFormat:@"   %@",[pth stringByDeletingPathExtension]]];
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
        NSArray* files = [openDlg URLs];
        for( int i = 0; i < [files count]; i++ )
            [theApp encryptFolder:[[files objectAtIndex:i] path]];
    }

}

- (IBAction)removeFS:(id)sender {
    DirectoryMap &dmap = getDirectories();
    int row = [table selectedRow];
    Folder dir =  dmap[row];
    if (dir) {
        if (dir->currStatus() == YoucryptDirectoryStatusMounted) {
            int ret = [self closeMountedFolder:dir];
            if (ret) {
                printCloseError(ret);
                return;
            }
        }
        
        int dirstatus = dir->currStatus();
        if (dirstatus == YoucryptDirectoryStatusNeedAuth ||
            dirstatus == YoucryptDirectoryStatusUnknown ||
            dirstatus == YoucryptDirectoryStatusUninitialized) {
            [table beginUpdates];
            [table removeRowsAtIndexes:[[NSIndexSet alloc] initWithIndex:row] withAnimation:NSTableViewAnimationSlideUp];
            [table endUpdates];
            dmap.erase(row);
        } else if (dirstatus == YoucryptDirectoryStatusInitialized) {
            long retCode;
            NSString *pth = nsstrFromCpp(dir->rootPath());
            if((retCode = [[NSAlert alertWithMessageText:@"Decrypt and Restore" defaultButton:@"Yes" alternateButton:@"No, delete the data." otherButton:@"Cancel" informativeTextWithFormat:@"You have chosen to permanently decrypt the encrypted folder at %@.  Restore contents?", [pth stringByDeletingLastPathComponent]] runModal]) == NSAlertDefaultReturn) {
                [theApp removeFSAtPath:pth];
            }
            else if (retCode == NSAlertAlternateReturn) {
                dmap.erase(row);
            }
//            NSImage *generic = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
//            BOOL didSetIcon = [[NSWorkspace sharedWorkspace] setIcon:generic forFile:[[dir path] stringByDeletingLastPathComponent] options:0];
//            NSLog(@"Icon reset : %d for %@",didSetIcon,[[dir path] stringByDeletingLastPathComponent]);
            
        }
    }
    [dirName setStringValue:@""];
    [table reloadData];
}

- (int)closeMountedFolder:(Folder)dir
{
    return dir->unmount();
}

void printCloseError(int ret)
{
    if (ret != 0) {
        NSString *errString = [NSString stringWithFormat:@"%s", strerror(ret)];
        [[NSAlert alertWithMessageText:errString defaultButton:@"OK" alternateButton:nil  otherButton:nil informativeTextWithFormat:@""] runModal];
    } else if (ret == -1) {
        [[NSAlert alertWithMessageText:@"Closing directory failed: unknown error" defaultButton:@"OK" alternateButton:nil  otherButton:nil informativeTextWithFormat:@""] runModal];
    }
    
}


- (IBAction)close:(id)sender {
    NSInteger row = [table selectedRow];
    DirectoryMap &dmap = getDirectories();
    int count = dmap.size();
    if (row < count) {
        DirectoryMap::iterator beg = dmap.begin();
        for (int i=0; i<row; i++)
            ++beg;
        Folder dir = beg->second;
        int ret = [self closeMountedFolder:dir];
        printCloseError(ret);
        
    }
    [table reloadData];
}

- (IBAction) shareFolder:(id) sender {
    
    DirectoryMap &dmap = getDirectories();
    int row = [table selectedRow];
    int count = dmap.size();
    if (row == -1) return;
    if (row < count) {
        DirectoryMap::iterator beg = dmap.begin();
        for (int i=0; i<row; i++)
            ++beg;
        Folder dir = beg->second;
        [sharingGetEmailsView setListDirWindow:self];
        [sharingPopover showRelativeToRect:[table rectOfRow:row] ofView:table preferredEdge:NSMaxYEdge];
        
        if ([[theApp.preferenceController getPreference:(MacUISettings::MacPreferenceKeys::yc_anonymousstatistics)] intValue])
            [mixpanel track:nsstrFromCpp(appSettings()->mixPanelUUID)
                 properties:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"YES", @"shareClicked",
                             nil]];
    }
}
         
-(BOOL)performShare:(NSString*)email
            message:(NSString*)msg
{
    BOOL ret = YES;
    NSString *fromname = [theApp.preferenceController getPreference:(MacUISettings::MacPreferenceKeys::yc_userrealname)];
    NSString *fromemail = [NSString stringWithFormat:@"%@ <%@>", fromname, [theApp.preferenceController getPreference:(MacUISettings::MacPreferenceKeys::yc_useremail)]];
    yc::UserAccount ua_to_search(cppString(email), "");
    DDLogVerbose(@"Searching for email %@ in server database", email);
    boost::shared_ptr<ServerConnectionWrapper> sc = [theApp getServerConnection];
    yc::Key k = sc->getPublicKey(ua_to_search);
    if (k.empty) {
        std::cout << "Key not found / is empty" << std::endl;
        [[NSNotificationCenter defaultCenter] postNotificationName:YC_SERVEROPS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:@"Could not find email in server database. Invite sent" forKey:@"message"]];
        NSString *subj = [NSString stringWithFormat:@"%@ wants to share an encrypted folder with you using YouCrypt!", fromname];
        NSString *mess = [NSString stringWithFormat:@"Hi %@, \n\n%@ wants to share an encrypted folder with you. Message follows:\n\n\t%@\n\n\nPlease download YouCrypt by going to %@ to share and receive shared files with YouCrypt.\n\nCheers,\nThe YouCrypt Team\n", email, fromemail, msg, YC_YOUCRYPT_DOWNLOADLOCATION];
        [theApp sendEmail:email from:fromemail subject:subj message:mess];
        return NO;
    }
    
    std::cout << "Got key " << k.value() << std::endl;
    // Create a Credential object wtih the retrieved key
    char *tmpfile = tmpnam(NULL); // tmpfile is a static buffer so doesn't need dealloc
    if (tmpfile) {
        // Create new credentials object with this user's keys
        std::string tmp_pub(tmpfile);
        std::map <std::string, std::string> empty;
        k.writeValueToFile(tmp_pub);
        CredentialStorage cs(new RSACredentialStorage("", tmp_pub, empty));
        Credentials c(new RSACredentials("", cs));
            
        // Get the currently selected folder's YCFolder object
        DirectoryMap &dmap = getDirectories();
        int row = [table selectedRow];
        int count = dmap.size();
        if (row < count) {
            DirectoryMap::iterator beg = dmap.begin();
            for (int i=0; i<row; i++, ++beg);
            Folder dir = beg->second;
            if (!dir->addCredential(c)) {
                DDLogError(@"Adding credentials failed!");
                [[NSNotificationCenter defaultCenter] postNotificationName:YC_KEYOPS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:@"Adding Credentials Failed" forKey:@"message"]];
                ret = NO;
            } else {
                [theApp sendEmail:email from:fromemail
                          subject:[NSString stringWithFormat:@"%@ wants to share an encrypted folder with you with YouCrypt!", fromname]
                          message:[NSString stringWithFormat:@"Hi %@, \n\n%@ wants to share an encrypted folder, %@, with you. Message follows:\n\n\t%@\n\n\nCheers,\nThe YouCrypt Team\n", email, fromname,
                                   nsstrFromCpp(dir->alias()), msg, YC_YOUCRYPT_DOWNLOADLOCATION]];
            }
        } else {
            DDLogError(@"row (%d)< count (%d)!", row, count);
            ret = NO;
        }
        
        if (!boost::filesystem::remove(boost::filesystem::path(tmp_pub))) {
            DDLogError(@"Error removing temporary file %s", tmp_pub.c_str());
        }
    } else {
        DDLogError(@"Cannot create tmp pubkey file for %@'s cred!", email);
        ret = NO;
    }
            
    return ret;
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
            RemoveToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
            PreferencesToolbarItemIdentifier, NSToolbarSeparatorItemIdentifier,
            HelpToolbarItemIdentifier, nil];
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
            ChangePassphraseToolbarIdentifier, NSToolbarSpaceItemIdentifier,
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
                                                                              @"Encrypt" /* label */, 
                                                                              @"Create" /* palletelabel */,
                                                                              @"Encrypt a folder" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"encrypt.png" /* image file */,
                                                                              NSStringFromSelector(@selector(addNew:)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:0]];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Decrypt" /* label */, 
                                                                              @"Remove" /* palletelabel */,
                                                                              @"Permanently decrypt an encrypted folder" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"decrypt.png" /* image file */,
                                                                              NSStringFromSelector(@selector(removeFS:)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:1]];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Settings" /* label */, 
                                                                              @"Settings" /* palletelabel */,
                                                                              @"Configure YouCrypt" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Preferences.png" /* image file */,
                                                                              NSStringFromSelector(@selector(showPreferencePanel)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:2]];
    

    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Change Passphrase" /* label */, 
                                                                              @"Change Passphrase" /* palletelabel */,
                                                                              @"Change your YouCrypt passphrase" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Key.png" /* image file */,
                                                                              NSStringFromSelector(@selector(showChangePassphraseSheet)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:3]];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Exit" /* label */, 
                                                                              @"Exit" /* palletelabel */,
                                                                              @"Quit Youcrypt" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Exit.png" /* image file */,
                                                                              NSStringFromSelector(@selector(exitApp)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:4]];
    
    [allowedToolbarItemDetails setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              @"Help" /* label */, 
                                                                              @"Help" /* palletelabel */,
                                                                              @"Learn to use YouCrypt" /* Tooltip */,
                                                                              self           /* target */,
                                                                              @"Help.png" /* image file */,
                                                                              NSStringFromSelector(@selector(showHelp)) /* selector */, nil]
                                                                     forKeys:toolbarItemKeys] 
                                  forKey:[allowedToolbarItemKeys objectAtIndex:5]];
}

- (void)showPreferencePanel
{
//    NSLog(@"Called showPreferences");
    [theApp showPreferencePanel:theApp];
}

- (void) exitApp 
{
//    NSLog(@"Called terminate");
    [theApp terminateApp:self];
}
- (void) showHelp 
{
//    NSLog(@"Called showHelp");
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://youcrypt.com/alpha/help/"]];
}


- (void) showChangePassphraseSheet 
{
    [passphraseSheet.message setStringValue:@"HELLO!"];
        
    DirectoryMap &dmap = getDirectories();
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (auto d: dmap) {
        [arr addObject:[NSString stringWithCString:d.first.c_str()
                                          encoding:NSASCIIStringEncoding]];
    }
    passphraseSheet.arr = arr;
    [passphraseSheet beginSheetModalForWindow:theApp.listDirectories.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            DDLogVerbose(@"showChangePassphraseSheet: Change Passphrase done");
        } else if (returnCode == kSheetReturnedCancel) {
            DDLogVerbose(@"showChangePassphraseSheet: Change Passphrase cancelled :( ");
        } else {
            DDLogVerbose(@"showChangePassphraseSheet: Unknown return code");
        }
    }];
}

@end
