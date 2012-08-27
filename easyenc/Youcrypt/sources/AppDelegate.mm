//
//  AppDelegate.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"
#import "PreferenceController.h"
#import "Decrypt.h"
#import "Encrypt.h"
#import "YoucryptService.h"
#import "libFunctions.h"
#import "ConfigDirectory.h"
#import "ListDirectoriesWindow.h"
#import "FirstRunSheetController.h"
#import "FeedbackSheetController.h"
#import "PeriodicActionTimer.h"
#import "CompressingLogFileManager.h"
#import "TourWizard.h"
#import "DBLinkedView.h"
#import "MixpanelAPI.h"
#import "AboutController.h"
#import "PassphraseManager.h"

/* Global Variables Accessible to everyone */
/* These variables should be initialized */
AppDelegate *theApp;
CompressingLogFileManager *logFileManager;
MixpanelAPI *mixpanel;

int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation AppDelegate

@synthesize window = _window;
@synthesize encryptController;
@synthesize decryptController;
@synthesize listDirectories;
@synthesize configDir;
@synthesize directories;
@synthesize firstRunSheetController;
@synthesize feedbackSheetController;
@synthesize keyDown;
@synthesize preferenceController;
@synthesize tourWizard;
@synthesize fileLogger;
@synthesize dropboxEncryptedFolders;
@synthesize mixpanelUUID;
@synthesize aboutController;
@synthesize passphraseManager;


// --------------------------------------------------------------------------------------
// App events
// --------------------------------------------------------------------------------------
- (id) init {
    self = [super init];
    
    configDir = [[ConfigDirectory alloc] init];
    youcryptService = [[YoucryptService alloc] init];
    
    preferenceController = [[PreferenceController alloc] init];
    listDirectories = [[ListDirectoriesWindow alloc] init];
    
    
    firstRunSheetController = [[FirstRunSheetController alloc] init];
    feedbackSheetController = [[FeedbackSheetController alloc] init];
    
    //[youcryptService setApp:self];
    
    // TODO:  Load up directories array from the list file.
    
    // Notifiers to indicate when app gains and loses focus
    // This is to do background stuffl ike syncing the config directory to disk
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidResignActive:)
                                                 name:NSApplicationDidResignActiveNotification
                                               object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:NSApplicationDidBecomeActiveNotification
                                               object:nil ];
    timer = [[PeriodicActionTimer alloc] initWithMinRefreshTime:5];
    configDirBeingSynced = NO;
    
    theApp = self;
    dropboxEncryptedFolders = [[NSMutableSet alloc] init];
    mixpanel = [MixpanelAPI sharedAPIWithToken:MIXPANEL_TOKEN];
    NSError *error = nil;
    mixpanelUUID = [NSString stringWithContentsOfFile:configDir.youcryptUserUUID encoding:NSASCIIStringEncoding error:&error];
    [mixpanelUUID stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    DDLogVerbose(@"mixpanel uuid : %@",mixpanelUUID);

    encryptQ = [[NSMutableArray alloc] init];
    decryptQ = [[NSMutableArray alloc] init];
    restoreQ = [[NSMutableArray alloc] init];
    
//    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(unarchiveDirectoryList:) name:@"YoucryptReceivedPassphraseFromUser" object:nil];
    
    passphraseManager = [[PassphraseManager alloc] initWithPrefController:preferenceController saveInKeychain:NO];
    
    
    // XXX FIXME Change for Release
#ifdef DEBUG
    mixpanel.dontLog = YES;
#elif RELEASE
    mixpanel.dontLog = NO;
#endif
    
    return self;
}


-(id) unarchiveDirectoryList:(id) sender {
    directories = [libFunctions unarchiveDirectoryListFromFile:configDir.youCryptListFile];
    if (directories == nil) {
        directories = [[NSMutableArray alloc] init];
    } else {
        // Do stuff here to check if dirs are all fine?
    }
//    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:@"YoucryptReceivedPassphraseFromUser" object:nil];
    return nil;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [NSApp setServicesProvider:youcryptService];
    
    // Logging
    logFileManager = [[CompressingLogFileManager alloc] initWithLogsDirectory:configDir.youCryptLogDir];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];    
    
    // Make sure only one instance of Youcrypt runs
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications]; 
    int ycAppCount = 0;
    
    for(NSRunningApplication *app in apps) {
        if([[app localizedName] isEqualToString:[[NSProcessInfo processInfo] processName]]) {
            ycAppCount++;
            if(ycAppCount > 1) {
                DDLogVerbose(@"FATAL. Cannot run multiple instances. Terminating!!");
                [self terminateApp:self];
            }
        }
    }
    
    YoucryptDirectory *dir;
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(someUnMount:) name:NSWorkspaceDidUnmountNotification object:nil];
    [self someUnMount:nil];

    DDLogVerbose(@"App did, in fact, finish launching!!!");

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    //[NSKeyedArchiver archiveRootObject:directories toFile:configDir.youCryptListFile];
    [libFunctions archiveDirectoryList:directories toFile:configDir.youCryptListFile];
    
    // Unmount all mounted directories
    // XXX check unmount status!
    for (id dir in directories) {
        [libFunctions execCommand:UMOUNT_CMD arguments:[NSArray arrayWithObject:[dir mountedPath]]
                              env:nil];
    }
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void) applicationDidResignActive:(NSNotification *)notification
{
    if (configDirBeingSynced == NO && [timer timerElapsed]) {
        configDirBeingSynced = YES;
        // XXX break this off into a new thread?
        /// XX might want to use a dispatch queue here instead
        [libFunctions archiveDirectoryList:directories toFile:configDir.youCryptListFile];
//        [NSKeyedArchiver archiveRootObject:directories toFile:configDir.youCryptListFile];
        
        configDirBeingSynced = NO;
    }
}
- (void) applicationDidBecomeActive:(NSNotification *)notification
{
//    NSLog(@"Became active");
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self showListDirectories:self];
    return YES;
}



- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    NSLog(@"openFile");
    return [self openEncryptedFolder:filename];
}

- (void)awakeFromNib{
    
    //--------------------------------------------------------------------------------------------------
    // Add UI related initializations here.
    //--------------------------------------------------------------------------------------------------
    
    // status icon
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *statusItemImage = [NSImage imageNamed:@"logo-color-alpha.png"];
    //[statusItem setTitle:@"YC"];
    [statusItem setImage:statusItemImage];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    
    
    NSLog(@"Awakefromnib");
    
    if([configDir isFirstRun]) {
        //[self showListDirectories:self];
        DDLogInfo(@"Initiating First Run! ");

        [self showTour];
        
//        NSString *error;
//        if (![self updatePBS:&error]) {
//            DDLogVerbose(@"Update PBS failed: %@", error);
//        }
    } else {
        [passphraseManager getPassphraseFromUser]; // get passphrase
    }
    
    NSUpdateDynamicServices(); // Equivalent to calling /System/Library/CoreServices/pbs
    
//    NSArray *args = [[NSProcessInfo processInfo] arguments];
//    if ([args count] > 1) {
//        NSLog(@"args:%@ ", args);
//        [self openEncryptedFolder:[args objectAtIndex:1]];
//    }

}
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Decryption methods
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
- (BOOL)openEncryptedFolder:(NSString *)path {
    //--------------------------------------------------------------------------------------------------
    // 1.  Check if path is really a folder
    // 2.  Check if we know bout it in our list of folders. If not, create and add it to list
    // 3.  Open it using Applescript or openFile
    //--------------------------------------------------------------------------------------------------
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL ret = YES;
    if (!([fm fileExistsAtPath:path isDirectory:&isDir] && isDir && ([[path pathExtension] isEqualToString:ENCRYPTED_DIRECTORY_EXTENSION])))
        return NO;
    
    
    // Check if a YoucryptDirectory already exists for this folder
    YoucryptDirectory *dir;
    for (dir in directories) {
        if ([path isEqualToString:dir.path])
            goto FoundOne;
    }
    
    // No directory exists; so create a new one
    dir = [[YoucryptDirectory alloc] initWithPath:path];
    dir.alias = [[path stringByDeletingPathExtension] lastPathComponent];
    [directories addObject:dir]; // FIXME do this later
    
FoundOne:
    // If dir is not mounted yet, construct mount point dir name
    if ([dir status] == YoucryptDirectoryStatusInitialized) {
        // Construct the new mount point dir name
        NSString *timeStr = [[[NSDate date] descriptionWithCalendarFormat:nil timeZone:nil locale:nil] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *mountPoint = [configDir.youCryptVolDir stringByAppendingPathComponent:
                                [timeStr stringByAppendingPathComponent:[[path stringByDeletingPathExtension] lastPathComponent]]];
        dir.mountedPath = mountPoint;
    }
    
    switch([dir status]) {
        case YoucryptDirectoryStatusUnknown:
        case YoucryptDirectoryStatusConfigError:
            DDLogError(@"Error opening supposedly Youcrypted dir: %@", [dir getStatus]);
            ret = NO;
            break;
            
        case YoucryptDirectoryStatusInitialized:
            [self doDecrypt:dir];
            break;
            
        case YoucryptDirectoryStatusMounted:
            [libFunctions openMountedPathInFinderSomehow:dir.path mountedPath:dir.mountedPath];
            break;
    }
    
    return ret;
}

- (void)didDecrypt:(YoucryptDirectory *)dir {
    
    if (dir == nil) return;
    
    
    dir.mountedDateAsString = [[NSDate date] descriptionWithCalendarFormat:@"%H:%M %m-%d-%Y" timeZone:nil locale:nil];
    [libFunctions openMountedPathInFinderSomehow:dir.path mountedPath:dir.mountedPath];
    
    DDLogVerbose(@"didDecrypt folder %@\n", dir.path);
    
    if (listDirectories != nil) {
        [listDirectories.table reloadData];
    }
    @synchronized(self) {
        [decryptQ removeObjectAtIndex:deQIndex];
    }
    [self doDecrypt:nil];
}

- (BOOL)doDecrypt:(YoucryptDirectory *)dir  {
    
    if ([configDir isFirstRun])
        return NO;
    NSString *path, *mountPath;
    
    if (dir == nil) {
        // Pick the next object from the queue and decrypt.        
        BOOL doReturn;
        doReturn = NO;
        @synchronized(self) {
            if ([decryptQ count] > 0) {
                NSDictionary *dict = [decryptQ lastObject];
                path = [dict objectForKey:@"path"];
                mountPath = [dict objectForKey:@"mountPoint"];
                deQIndex = [decryptQ count] - 1;
            }
            else {
                // Nothing to service.
                doReturn = YES;
            }
        }
        if (doReturn)
            return NO;
    } else {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              dir.path, @"path", dir.mountedPath, @"mountPoint", nil];
        BOOL doReturn = NO;
        @synchronized(self) {
            [decryptQ addObject:dict];
            if ([decryptQ count] > 1)
                doReturn = YES;
            else {
                deQIndex = 0; // Index of the object being processed.
            }
        }
        if (doReturn)
            return NO;
    }
    
    // Is decryptController nil?
    if (!decryptController) {
        decryptController = [[Decrypt alloc] init];
    }
    
    decryptController.dir = dir;
    
    NSString *pp = [passphraseManager getPassphrase];
    
    // NSString *pp =[libFunctions getPassphraseFromKeychain:@"Youcrypt"];
    DDLogInfo(@"showing %@", decryptController);
    
    if ((pp != nil) && !([pp isEqualToString:@""])) {
        DDLogVerbose(@"In doDecrypt: Got pp from keychain successfully");
        decryptController.passphraseFromKeychain = pp;
        decryptController.keychainHasPassphrase = YES;
        [decryptController decrypt:self];
    }
    else {
        decryptController.keychainHasPassphrase = NO;
        [decryptController showWindow:self];
    }
    return YES;
}

-(void) cancelDecrypt:(YoucryptDirectory *)dir {
    @synchronized(self) {
        [decryptQ removeObjectAtIndex:deQIndex];
    }
    dir = nil;
    [self doDecrypt:nil];
}


// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Encryption methods
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

- (BOOL)encryptFolder:(NSString *)path {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if (!([fm fileExistsAtPath:path isDirectory:&isDir] && isDir))
        return NO;
    
    // Ok, this is a directory, but is it an already encrypted directory?
    if ([[path pathExtension] isEqualToString:ENCRYPTED_DIRECTORY_EXTENSION] &&
        [fm fileExistsAtPath:[path stringByAppendingPathComponent:YOUCRYPT_XMLCONFIG_FILENAME]]) {
        long ret = [[NSAlert alertWithMessageText:@"Directory already encrypted" defaultButton:@"Yes" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"The directory %@ appears to already be encrypted using Youcrypt. Did you mean to decrypt it permanently instead?", [path stringByDeletingLastPathComponent]] runModal];
        if (ret == NSAlertDefaultReturn) {
            [self removeFSAtPath:path];
        }
    } else {
        [self doEncrypt:path];
    }
    return YES;
}

- (BOOL)doEncrypt:(NSString *)path {
    if (path == nil) {
        BOOL doReturn = NO;
        // Pick the next object from the queue and encrypt.
        @synchronized(self) {
            if ([encryptQ count] > 0) {
                path = [encryptQ lastObject];
                enQIndex = [encryptQ count] - 1;
            }
            else {
                // Nothing to service.
                doReturn = YES;
            }
        }
        if (doReturn)
            return NO;
    } else {
        BOOL doReturn = NO;
        @synchronized(self) {
            [encryptQ addObject:path];
            if ([encryptQ count] > 1)
                doReturn = YES;
            else
                enQIndex = 0;
        }
        if (doReturn)
            return NO;
    }
    
    // Is encryptController nil?
    if (!encryptController) {
        encryptController = [[Encrypt alloc] init];
    }
    
    [listDirectories.statusLabel setStringValue:@"Encrypting"];
    [listDirectories.progressIndicator setHidden:NO];
    [listDirectories.progressIndicator startAnimation:listDirectories.window];
    
    
    NSString *pp =[passphraseManager getPassphrase];
    encryptController.sourceFolderPath = path;
    
    if (pp != nil && [pp isNotEqualTo:@""]) {
        DDLogVerbose(@"In doEncrypt: Got pp from keychain successfully");
        encryptController.passphraseFromKeychain = pp;
        encryptController.keychainHasPassphrase = YES;
        [encryptController encrypt:self];
    } else {
        NSButton *storePasswd = encryptController.checkStorePasswd;
        [storePasswd setState:NSOnState];
        encryptController.passphraseFromKeychain = nil;
        encryptController.keychainHasPassphrase = NO;
        [encryptController showWindow:self];        
    }
    return YES;
}


- (void)didEncrypt:(YoucryptDirectory *)dir {
    NSImage *overlay = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/youcrypt-overlay.icns"]];
    BOOL didSetIcon = [[NSWorkspace sharedWorkspace] setIcon:overlay forFile:dir.path options:0];
    if(!didSetIcon)
        DDLogInfo(@"ERROR: Could not set Icon for %@", dir.path);
    
    dir.alias = [[dir.path stringByDeletingPathExtension] lastPathComponent];
    dir.mountedDateAsString = [[NSDate date] descriptionWithCalendarFormat:@"%H:%M %m-%d-%Y" timeZone:nil locale:nil];
    [directories addObject:dir];
    if (listDirectories != nil) {
        [listDirectories.statusLabel setStringValue:@""];
        [listDirectories.progressIndicator stopAnimation:listDirectories.window];
        [listDirectories.progressIndicator setHidden:YES];
        [listDirectories.table reloadData];
    }
    @synchronized(self) {
        [encryptQ removeObjectAtIndex:enQIndex];
    }
    [self doEncrypt:nil]; // To process other items in encryptQ
    
}

- (void)cancelEncrypt:(NSString *)path {
    @synchronized(self) {
        [encryptQ removeObjectAtIndex:enQIndex];
    }
    DDLogInfo(@"Canceling encryption for %@", path);
    [self doEncrypt:nil]; // To process other items in encryptQ
}

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Restore methods
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

- (void) removeFSAtRow:(long) row {
    YoucryptDirectory *dir = [directories objectAtIndex:row];
    [self doRestore:dir.path];
}

- (void) removeFSAtPath:(NSString*) path {

    int i = 0, found = 0;
    for (YoucryptDirectory *dir in directories) {
        if ([dir.path isEqualToString:path]) {
            [self doRestore:path];
            found = 1;
            break;
        }
        i++;
    }
    
    if (!found) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([[path pathExtension] isEqualToString:ENCRYPTED_DIRECTORY_EXTENSION] &&
            [fm fileExistsAtPath:[path stringByAppendingPathComponent:YOUCRYPT_XMLCONFIG_FILENAME]]) {
            long ret = [[NSAlert alertWithMessageText:@"Unknown encrypted directory" defaultButton:@"Yes" alternateButton:@"No, decrypt permanently" otherButton:nil informativeTextWithFormat:@"The encrypted directory %@ is not known to Youcrypt (e.g., perhaps it has been moved or copied). Do you wish to register this encrypted directory with Youcrypt?", [path stringByDeletingLastPathComponent]] runModal];
            if (ret == NSAlertDefaultReturn) {
                [self openEncryptedFolder:path];
            } else if (ret == NSAlertAlternateReturn) {
                [self doRestore:path];
            } else {
                return;
            }
        }
            
    }
}

- (BOOL)doRestore:(NSString *)path {

    if ([configDir isFirstRun])
        return NO;

    if (path == nil) {
        BOOL doReturn = NO;
        // Pick the next object from the queue and restore.        
        @synchronized(self) {
            if ([restoreQ count] > 0) {
                path = [restoreQ lastObject];
                reQIndex = [restoreQ count] - 1;
            }
            else {
                doReturn = YES;
            }
        }
        if (doReturn)
            return NO;
    } else {
        BOOL doReturn = NO;
        @synchronized(self) {
            [restoreQ addObject:path];
            if ([restoreQ count] > 1)
                doReturn = YES;
            else
                reQIndex = 0;
        }
        if (doReturn)
            return NO;
    }
    
    YoucryptDirectory *d = nil;
    for (YoucryptDirectory *dir in directories) {
        if ([dir.path isEqualToString:path]) {
            d = dir;
            break;
        }
    }
    if (d == nil) {
        d = [[YoucryptDirectory alloc] initWithPath:path];
        
        if ([d status] != YoucryptDirectoryStatusInitialized) {
            DDLogError(@"Directory to be restored looks like something something else; status %@", [d getStatus]);
            return NO;
        }
    }
        
    if (!restoreController) {
        restoreController = [[RestoreController alloc] init];
    }
    
    [listDirectories.statusLabel setStringValue:@"Restoring"];
    [listDirectories.progressIndicator setHidden:NO];
    [listDirectories.progressIndicator startAnimation:listDirectories.window];
    
    
    restoreController.path = path;
    restoreController.dir = d;
    NSString *pp = [passphraseManager getPassphrase];
    if (pp != nil && !([pp isEqualToString:@""])) {
        DDLogVerbose(@"In doRestore: Got pp from keychain successfully");
        restoreController.passwd = pp;
        restoreController.keychainHasPassphrase = YES;
        [restoreController restore:self];
    }
    else {
        restoreController.keychainHasPassphrase = NO;
        [restoreController showWindow:self];
    }
    return YES;
}

- (void)didRestore:(NSString *)path {
    for (YoucryptDirectory *dir in directories) {
        if ([path isEqualToString:dir.path]) {
            [directories removeObject:dir];
            break;
        }
        
    }
    
    if (listDirectories != nil) {
        [listDirectories.statusLabel setStringValue:@""];
        [listDirectories.progressIndicator stopAnimation:listDirectories.window];
        [listDirectories.progressIndicator setHidden:YES];
        [listDirectories.table reloadData];
    }
    @synchronized(self) {
        [restoreQ removeObjectAtIndex:reQIndex];
    }
    [self doRestore:nil];
}

-(void) cancelRestore:(NSString *)path {
//    for (YoucryptDirectory *dir in directories) {
//        if ([path isEqualToString:dir.path]) {
//            dir.status = YoucryptDirectoryStatusUnmounted; // Should've been processing
//            [dir updateInfo];
//            break;
//        }
//        
//    }    
    @synchronized(self) {
        [restoreQ removeObjectAtIndex:reQIndex];
    }
    [self doRestore:nil];
}


- (IBAction)windowShouldClose:(id)sender {
    //DDLogVerbose(@"Closing..");
}

- (IBAction)terminateApp:(id)sender {
    DDLogInfo(@"Going to terminate App.");
    [NSApp terminate:nil];
}



// --------------------------------------------------------------------------------------
// Helper functions to show any window; you name it, we've it.
// --------------------------------------------------------------------------------------
- (IBAction)showMainApp:(id)sender {
    if ([configDir isFirstRun])
        return;
        
    [listDirectories.window makeKeyAndOrderFront:self];
}

- (IBAction)showListDirectories:(id)sender {
    if ([configDir isFirstRun])
        return;
    
    // Is list directories nil?
//    if (!listDirectories) {
//        listDirectories = [[ListDirectoriesWindow alloc] init];
//    }
    //[listDirectories.window makeKeyAndOrderFront:self];
    [listDirectories showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
    
}

- (IBAction)showPreferencePanel:(id)sender {
    if ([configDir isFirstRun])
        return;
    
    // Is preferenceController nil?
//    if (!preferenceController) {
//        preferenceController = [[PreferenceController alloc] init];
//    }
    [preferenceController showWindow:self];
}

//- (void)showFirstRunSheet {
//    // Is preferenceController nil?
//    if (!preferenceController) {
//        preferenceController = [[PreferenceController alloc] init];
//    }
//    [self showFirstRun]; 
//    
//}

- (IBAction)showAboutWindow:(id)sender {

    // Is preferenceController nil?
    if (!aboutController) {
        aboutController = [[AboutController alloc] init];
    }
    [aboutController.window makeKeyAndOrderFront:nil];
}

-(void) showTour {
    if (!tourWizard) {
        tourWizard = [[TourWizard alloc] init];
    }
    
    [tourWizard showWindow:self];
}



- (IBAction)openFeedbackPage:(id)sender
{
    //[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://youcrypt.com"]];
    [feedbackSheetController beginSheetModalForWindow:theApp.listDirectories.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            DDLogVerbose(@"feedbackSheetController: Feedback run done");
            [self.window close];
        } else if (returnCode == kSheetReturnedCancel) {
            DDLogVerbose(@"feedbackSheetController: Feedback cancelled :( ");
        } else {
            DDLogVerbose(@"feedbackSheetController: Unknown return code");
        }
    }];

}

- (IBAction)openHelpPage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://youcrypt.com/alpha/help"]];
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

- (void)keyDown:(NSEvent *)theEvent
{
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
   
    NSString *colId = [tableColumn identifier];
    
    if (!directories)
        return nil;
    
    YoucryptDirectory *dirAtRow = [directories objectAtIndex:row];
    if (!dirAtRow)
        return nil;
    
//    [dirAtRow updateInfo];
    
    
    if ([colId isEqualToString:@"alias"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:dirAtRow.alias];
        NSRange selectedRange = NSRangeFromString(dirAtRow.alias);
        [str addAttribute:NSForegroundColorAttributeName
                       value:[NSColor blueColor]
                       range:selectedRange];
        [str addAttribute:NSUnderlineStyleAttributeName
                       value:[NSNumber numberWithInt:NSSingleUnderlineStyle]
                       range:selectedRange];
        
        return str;
    } 
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
    
    BOOL ret = NO;    
    NSArray *fileURLs = nil;
    {
        NSArray *classes = [NSArray arrayWithObject:[NSURL class]];        
        fileURLs = [pb readObjectsForClasses:classes options:nil];
    }
            
    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {        
        NSFileManager *fm = [NSFileManager defaultManager];
       [listDirectories.table setDefaultImage];
        NSURL *url;
        for (url in fileURLs) {
            BOOL isDir;
            NSString *path = [url path];
            if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {                  
                // If it's a .yc folder and if it contains YOUCRYPT_XMLCONFIG_FILENAME ,
                //  we open it, otherwise, we encrypt it
                if ([[path pathExtension] isEqualToString:ENCRYPTED_DIRECTORY_EXTENSION] &&
                    [fm fileExistsAtPath:[path stringByAppendingPathComponent:YOUCRYPT_XMLCONFIG_FILENAME]]) {
                    [theApp openEncryptedFolder:path];
                }
                else {
                    [theApp encryptFolder:path];
                }
                ret = YES;
            }
        }
    }
    return ret;
}

//--------------------------------------------------------------------------------------------------
// Code to color mounted and unmounted folders separately and change their icons
//--------------------------------------------------------------------------------------------------
- (void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *colId = [tableColumn identifier];

 //  NSLog(@"This code called");
					
    if (!directories)
        return;
    
    YoucryptDirectory *dirAtRow = [directories objectAtIndex:row];
    if (!dirAtRow)
        return;
        
//    [dirAtRow updateInfo];
    
    if ([dirAtRow status] == YoucryptDirectoryStatusMounted) { // mounted => unlocked
        if ([cell isKindOfClass:[NSTextFieldCell class]]) {
//            [cell setTextColor:[NSColor redColor]];
//            [cell setBackgroundColor:[NSColor grayColor]];
        } else if ([cell isKindOfClass:[NSButtonCell class]] && [colId isEqualToString:@"status"]) {
            [cell setImage:[NSImage imageNamed:@"box_open_48x48.png"]];
        } else if ([cell isKindOfClass:[NSPopUpButtonCell class]] && [colId isEqualToString:@"props"]) {
            /*NSPopUpButtonCell *dataTypeDropDownCell = [tableColumn dataCell];
            [[dataTypeDropDownCell itemAtIndex:1] setTitle:@"Close"];*/
            [[[tableColumn dataCell] itemAtIndex:2] setHidden:NO];
        }
    } else  { // unmounted => locked
        if ([cell isKindOfClass:[NSTextFieldCell class]]) {
//            [cell setTextColor:[NSColor blackColor]];
//            [cell setBackgroundColor:[NSColor darkGrayColor]];
            
        } else if ([cell isKindOfClass:[NSButtonCell class]] && [colId isEqualToString:@"status"]) {
            if ([dirAtRow status] == YoucryptDirectoryStatusInitialized)
                [cell setImage:[NSImage imageNamed:@"box_closed_48x48.png"]];
            else if ([dirAtRow status] == YoucryptDirectoryStatusConfigError || [dirAtRow status] == YoucryptDirectoryStatusUnknown)
                [cell setImage:[NSImage imageNamed:@"error-22x22.png"]];
            if ([dirAtRow status] == YoucryptDirectoryStatusProcessing)
                [cell setImage:[NSImage imageNamed:@"processing-22x22.gif"]];
        } else if ([cell isKindOfClass:[NSPopUpButtonCell class]] && [colId isEqualToString:@"props"]) {
            //NSPopUpButtonCell *dataTypeDropDownCell = [tableColumn dataCell];
            //NSLog(@"Trying to disable close");
            [[[tableColumn dataCell] itemAtIndex:2] setHidden:YES];
            
        }
    }
}

- (NSString *)tableView:(NSTableView *)aTableView toolTipForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{   
    NSString *tooltip;
    if (rowIndex >= 0) {
        YoucryptDirectory *dir = [directories objectAtIndex:rowIndex];
        tooltip = [NSString stringWithFormat:@"Source folder: %@\n\n"
                             "Status: %@"
                             "%@", dir.path, [dir getStatus],
                             ([dir status] == YoucryptDirectoryStatusMounted ? [NSString stringWithFormat:@"\n\nMounted at %@", dir.mountedPath] : @"")];
    } else {
        tooltip = @"Drag folders here to encrypt them with YouCrypt";
    }

    return tooltip;
}

- (id) tableView:(NSTableView*)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    /*
    NSString *colId = [tableColumn identifier];

    if ([colId isEqualToString:@"props"]) {
        NSPopUpButtonCell *dataTypeDropDownCell = [[NSPopUpButtonCell alloc] initTextCell:@"Actions..." pullsDown:YES];
        [dataTypeDropDownCell setBordered:NO];
        [dataTypeDropDownCell setEditable:YES];
        NSArray *dataTypeNames = [NSArray arrayWithObjects:@"NULLOrignal", @"String", @"Money", @"Date", @"Int", nil];
        [dataTypeDropDownCell addItemsWithTitles:dataTypeNames];
        return dataTypeDropDownCell;
    } else {
        return nil;
    }
     */
    return nil;
}


-(id) someUnMount:(id) sender {
    // Someone unmount us a bomb.
    DDLogVerbose(@"Something unmounted\n");
//    [YoucryptDirectory refreshMountedFuseVolumes];
//    YoucryptDirectory *dir;
//    for (dir in directories) {
//        [dir updateInfo];
//    }
    if (listDirectories != nil)
        [listDirectories.table reloadData];
    return nil;
}

@end
