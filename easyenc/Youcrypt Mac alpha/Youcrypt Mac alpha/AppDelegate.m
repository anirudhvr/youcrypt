//
//  AppDelegate.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferenceController.h"
#import "FileSystem.h"
#import "Decrypt.h"
#import "Encrypt.h"
#import "YoucryptService.h"
#import "YoucryptConfigDirectory.h"
#import "libFunctions.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"
#import "CompressingLogFileManager.h"
#import "logging.h"
#import "YoucryptConfigDirectory.h"
#import "ListDirectoriesWindow.h"

#define prefsToolbar @"Prefs"
#define quitToolbar @"Quit"

int ddLogLevel = LOG_LEVEL_VERBOSE;


/* Global Variables Accessible to everyone */
/* These variables should be initialized */
AppDelegate *theApp;

@implementation AppDelegate

@synthesize window = _window;
@synthesize encryptController;
@synthesize decryptController;
@synthesize listDirectories;
@synthesize configDir;
@synthesize directories;

- (id) init
{
    self = [super init];
    
    configDir = [[YoucryptConfigDirectory alloc] init];
    youcryptService = [[YoucryptService alloc] init];

    // TODO:  Load up directories array from the list file.
    directories = [NSKeyedUnarchiver unarchiveObjectWithFile:configDir.youCryptListFile];
    
    theApp = self;
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [NSApp setServicesProvider:youcryptService];
    
    // Logging
    CompressingLogFileManager *logFileManager = [[CompressingLogFileManager alloc] initWithLogsDirectory:configDir.youCryptLogDir];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];    
    DDLogVerbose(@"App did, in fact, finish launching!!!");
}


- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{    
    return [self openEncryptedFolder:filename];
}

- (BOOL)openEncryptedFolder:(NSString *)path
{   
    //--------------------------------------------------------------------------------------------------
    // 1.  Check if path is really a folder
    // 2.  Check if the last component is encrypted.yc   <---- TODO
    // 3.  Check if it is already mounted                <---- TODO
    // 4.  o/w, mount and open it.
    //--------------------------------------------------------------------------------------------------
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        
        // 1. Set up a new mount point
        // 2. Set up decrypt controller with the path and the mount point
        // 3. Open the decrypt window
        
        NSString *mountPoint = [configDir.youCryptVolDir stringByAppendingPathComponent:[[NSProcessInfo processInfo]globallyUniqueString]];
        
        if (!decryptController) {
            decryptController = [[Decrypt alloc] init];
        }
        decryptController.destFolderPath = mountPoint;
        decryptController.sourceFolderPath = path;
        [self showDecryptWindow:self];        
        return YES;
    }
    return NO;
  
//    decryptController.sourceFolderPath = file;
//    NSString *dest = [[configDir.youCryptVolDir stringByAppendingPathComponent:file] stringByDeletingPathExtension];
//    decryptController.destFolderPath = dest;
//    
//    DDLogVerbose(@"The following file has been dropped or selected: %@",file);
//   
//    return  YES; // Return YES when file processed succesfull, else return NO.
}

- (void)encryptFolder:(NSString *)path {
    
    //--------------------------------------------------------------------------------------------------
    // Lots of shit
    //--------------------------------------------------------------------------------------------------    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        if (!encryptController) {
            encryptController = [[Encrypt alloc] init];
        }
        encryptController.sourceFolderPath = path;
        [self showEncryptWindow:self];
    }
}

-(void)awakeFromNib{
    
    //--------------------------------------------------------------------------------------------------
    // Add UI related initializations here.
    //--------------------------------------------------------------------------------------------------

    // status icon
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"YC"];
    [statusItem setHighlightMode:YES];

    // attach toolbar
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"tooltest"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES]; 
    
    [self.window setToolbar:toolbar];
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	NSString *type = [[NSString alloc] init];
    
	for (id arg in arguments) {
		if([arg isEqualToString:@"-d"]) {
			type = @"D"; // decrypt
		}
		else if([arg isEqualToString:@"-e"]) {
			type = @"E"; // encrypt
		}
        else if([arg isEqualToString:@"-m"]) {
            type = @"M";
        }
        else if([arg isEqualToString:@"-p"]) {
            type = @"P";
        }
        else type = @"M";
	}
    
    type = @"L";
    DDLogCVerbose(@"awake! %@",THIS_FILE);

    
    if([type isEqualToString:@"M"])
        [self showMainApp:self];
    
    else if([type isEqualToString:@"E"])
        [self showEncryptWindow:self];
    
    else if([type isEqualToString:@"D"])
        [self showDecryptWindow:self];
    
    else if ([type isEqualToString:@"P"])
        [self showPreferencePanel:self];
    
    else if ([type isEqualToString:@"L"])
        [self showListDirectories:self];
        
}


-(IBAction)windowShouldClose:(id)sender
{
    DDLogVerbose(@"Closing..");
}

-(IBAction)showMainApp:(id)sender
{
    [self.window makeKeyAndOrderFront:self];
}

- (IBAction)terminateApp:(id)sender
{
    [NSApp terminate:nil];
}

- (IBAction)showListDirectories:(id)sender
{
    // Is list directories nil?
    if (!listDirectories) {
        listDirectories = [[ListDirectoriesWindow alloc] init];
    }
    [listDirectories showWindow:self];
}


- (IBAction)showPreferencePanel:(id)sender
{
    // Is preferenceController nil?
    if (!preferenceController) {
        preferenceController = [[PreferenceController alloc] init];
    }
    DDLogVerbose(@"showing %@", preferenceController);
    [preferenceController showWindow:self];
}

- (IBAction)showDecryptWindow:(id)sender
{
    // Is decryptController nil?
    if (!decryptController) {
        decryptController = [[Decrypt alloc] init];
    }
    DDLogVerbose(@"showing %@", decryptController);
    [decryptController showWindow:self];
}

- (IBAction)showEncryptWindow:(id)sender
{
    // Is encryptController nil?
    if (!encryptController) {
        encryptController = [[Encrypt alloc] init];
    } else {
        /* other times, this code is called in awakefromNib */              
        if (encryptController.keychainHasPassphrase == NO) {
            encryptController.passphraseFromKeychain = [libFunctions getPassphraseFromKeychain];
            if (encryptController.passphraseFromKeychain != nil) {
                encryptController.keychainHasPassphrase = YES;
            }
        }
        NSString *passphrase =[libFunctions getPassphraseFromKeychain];
        if ([encryptController keychainHasPassphrase] == YES) {
            [encryptController setPassphraseTextField:passphrase];
        }
    }

    DDLogVerbose(@"showing %@", encryptController);
    [encryptController showWindow:self];
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
    if ([itemIdentifier isEqualToString:prefsToolbar]) {
            toolbarItem = [self toolbarItemWithIdentifier:prefsToolbar
                                                label:@"Preferences"
                                          paleteLabel:@"Preferences"
                                              toolTip:@"Open Preferences"
                                               target:self
                                          itemContent:[NSImage imageNamed:@"Settings.png"]
                                               action:@selector(showPreferencePanel:)
                           ];   
    }
    else if ([itemIdentifier isEqualToString:quitToolbar]) {
            toolbarItem = [self toolbarItemWithIdentifier:quitToolbar 
                                                label:@"Quit" 
                                          paleteLabel:@"Quit" 
                                              toolTip:@"Quit" 
                                               target:self 
                                          itemContent:[NSImage imageNamed:@"Cancel.png"] 
                                               action:@selector(terminateApp:)
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
    return [NSArray arrayWithObjects:   prefsToolbar, 
                                        NSToolbarSeparatorItemIdentifier,
                                        quitToolbar,
            nil];
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for all allowed
// toolbar items in this toolbar.  Any not listed here will not be available in the customization palette.
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:   prefsToolbar, 
                                        NSToolbarSeparatorItemIdentifier,
                                        quitToolbar,
            nil];
}



//--------------------------------------------------------------------------------------------------
// The AppDelegate is also our tableview's data source.  It populates shit using the directories array.
//--------------------------------------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (directories)
        return directories.count;
    else {
        return 0;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (!directories)
        return nil;
    
    YoucryptDirectory *dirAtRow = [directories objectAtIndex:row];
    if (!dirAtRow)
        return nil;
    
    NSString *colId = [tableColumn identifier];
    if ([colId isEqualToString:@"alias"])
        return dirAtRow.alias;
    else if ([colId isEqualToString:@"mountedPath"])
        return dirAtRow.mountedPath;    
    else {
        return nil;
    }
}




//--------------------------------------------------------------------------------------------------
// The tableview's data source also does drag drop
//--------------------------------------------------------------------------------------------------
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pb = [info draggingPasteboard];
    
    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    
    NSPasteboard *pb = [info draggingPasteboard];
    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            [theApp encryptFolder:path];
            [tableView reloadData];
            return YES;
        }
    }
    return NO;
}





@end
