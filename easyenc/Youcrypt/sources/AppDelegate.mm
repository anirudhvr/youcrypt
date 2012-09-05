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
#import "PortingQ.h"


using namespace youcrypt;

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

    
    passphraseManager = [[PassphraseManager alloc] initWithPrefController:preferenceController saveInKeychain:NO];
    
    
    // XXX FIXME Change for Release
#ifdef DEBUG
    mixpanel.dontLog = YES;
#elif RELEASE
    mixpanel.dontLog = NO;
#endif
    
    if (!directories) directories.reset(new DirectoryMap);
    return self;
}


-(id) passphraseReceivedFromUser:(id) sender {
    
    if (![configDir checkKeys]) {
        NSLog(@"Error checking config dir - key decrypt problem?");
    }
    NSString *s = [passphraseManager getPassphrase];
    std::string pass_cppstr = cppString(s);
    
    PortingCM *pcm = new PortingCM;
    pcm->setPassphrase(pass_cppstr);
    shared_ptr<youcrypt::CredentialsManager> p;
    p.reset(pcm);
    setGlobalCM(p);
    directories = [libFunctions unarchiveDirectoryListFromFile:configDir.youCryptListFile];
    if (!directories) {
        directories.reset(new DirectoryMap);
    }
    
    std::string userEmail = cppString([preferenceController getPreference:YC_USEREMAIL]);
    userAccount.reset(new UserAccount(userEmail, pass_cppstr));
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
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(someUnMount:) name:NSWorkspaceDidUnmountNotification object:nil];
    [self someUnMount:nil];
    
    DDLogVerbose(@"App did, in fact, finish launching!!!");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    //[NSKeyedArchiver archiveRootObject:directories toFile:configDir.youCryptListFile];
    [libFunctions archiveDirectoryList:directories toFile:configDir.youCryptListFile];
    
    // Unmount all mounted directories
    // XXX check unmount status!
    for (auto dir: *(directories.get()))
    {
        dir.second->unmount();
    }
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
    
    // Procedure:
    // 1.  check if path is a folder
    // 2.  check if path is an encrypted file
    // 3.  check/add path to our managed list
    // 4.  open the (mounted) path
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL ret = YES;
    if (!([fm fileExistsAtPath:path isDirectory:&isDir] && isDir && ([[path pathExtension] isEqualToString:ENCRYPTED_DIRECTORY_EXTENSION])))
        return NO;
    
    // Check if a Folder already exists for this folder
    DirectoryMap &dirs = *(directories.get());
    std::string strPath([path cStringUsingEncoding:NSASCIIStringEncoding]);
    Folder dir;
    dir = dirs[strPath];
    if (!dir)
    {
        dir = YCFolder::initFromScanningPath(strPath);
        // verify that we could read it
        switch (dir->currStatus()) {
            case YoucryptDirectoryStatusInitialized:
            case YoucryptDirectoryStatusNeedAuth:
                // Implies a folder that can be opened.
                break;
            default:
                return NO;
        }
        // good idea to go ahead and add it to our maintained list
        dirs[strPath] = dir;
    }
    
    NSString *timeStr = [[[NSDate date] descriptionWithCalendarFormat:nil timeZone:nil locale:nil] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *mountPoint = [configDir.youCryptVolDir stringByAppendingPathComponent:
                            [timeStr stringByAppendingPathComponent:[[path stringByDeletingPathExtension] lastPathComponent]]];
    
    // We have a valid dir object.  Let us go ahead and open it.
    switch (dir->currStatus()) {
        case YoucryptDirectoryStatusUnknown:
            // This should really never happen.
        case YoucryptDirectoryStatusUninitialized:
            // The folder does not have a config.
            return NO;
        case YoucryptDirectoryStatusBadConfig:
            return NO;
        case YoucryptDirectoryStatusInitialized:
        case YoucryptDirectoryStatusReadyToMount:
        case YoucryptDirectoryStatusNeedAuth:
        case YoucryptDirectoryStatusMounted:
            break;
    }
    
    if (dir->currStatus() == YoucryptDirectoryStatusMounted){
        [libFunctions openMountedPathInFinderSomehow:nsstrFromCpp(dir->rootPath())
                                         mountedPath:nsstrFromCpp(dir->mountedPath())];
    }
    
    decQ.queueJob(boost::make_tuple(dir->rootPath(), cppString(mountPoint)));
    dispatch_queue_t taskQ =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQ, ^{
        decQ.runTillEmpty();});

    
    return YES;
}

- (void)didDecrypt:(Folder)dir {
    if (!dir) return;
    
    // FIXME:  implement mountdateasstring in YCFolder
    [libFunctions openMountedPathInFinderSomehow:nsstrFromCpp(dir->rootPath())
                                     mountedPath:nsstrFromCpp(dir->mountedPath())];
    DDLogVerbose(@"didDecrypt folder %@\n", nsstrFromCpp(dir->rootPath()));
    
    if (listDirectories != nil) {
        [listDirectories.table reloadData];
    }
}

- (BOOL)doDecrypt:(NSString *)path
      mountedPath:(NSString *)mountPath {
    
    if ([configDir isFirstRun])
        return NO;
    
    // Is decryptController nil?
    if (!decryptController) {
        decryptController = [[Decrypt alloc] init];
    }
    Folder dir;
    DirectoryMap &dmap = *(directories.get());
    string strPath = cppString(path);
    dir = dmap[strPath];
    if (!dir)
        return NO;
    
    decryptController.dir = dir;
    decryptController.mountPath = mountPath;
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

- (void) cancelDecrypt:(Folder)dir {
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
        encQ.queueJob(cppString(path));
        dispatch_queue_t taskQ =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(taskQ, ^{
            encQ.runTillEmpty();});
    }
    return YES;
}

- (BOOL)doEncrypt:(NSString *)path {
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


- (void)didEncrypt:(Folder)dir {
    NSImage *overlay = [[NSImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath]
                         stringByAppendingPathComponent:@"/youcrypt-overlay.icns"]];
    BOOL didSetIcon = [[NSWorkspace sharedWorkspace]
                       setIcon:overlay forFile:nsstrFromCpp(dir->rootPath()) options:0];
    if(!didSetIcon)
        DDLogInfo(@"ERROR: Could not set Icon for %@", nsstrFromCpp(dir->rootPath()));
    
    NSString *p = nsstrFromCpp(dir->rootPath());
    dir->alias() = cppString([[p stringByDeletingPathExtension]
                              lastPathComponent]);
    DirectoryMap &dmap = *(directories.get());
    std::string strPath = dir->rootPath();
    dmap[strPath] = dir;
    if (listDirectories != nil) {
        [listDirectories.statusLabel setStringValue:@""];
        [listDirectories.progressIndicator stopAnimation:listDirectories.window];
        [listDirectories.progressIndicator setHidden:YES];
        [listDirectories.table reloadData];
    }
    
}

- (void)cancelEncrypt:(NSString *)path {
}

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Restore methods
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

- (void) removeFSAtPath:(NSString*) path {
    DirectoryMap &dmap = *(directories.get());
    std::string stdPath([path cStringUsingEncoding:NSASCIIStringEncoding]);
    int found;
    
    Folder dir = dmap[stdPath];
    
    dispatch_queue_t taskQ =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    if (dir) {
        resQ.queueJob(stdPath);
        found = 1;
    }
    
    if (!found) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([[path pathExtension] isEqualToString:ENCRYPTED_DIRECTORY_EXTENSION] &&
            [fm fileExistsAtPath:[path stringByAppendingPathComponent:YOUCRYPT_XMLCONFIG_FILENAME]]) {
            long ret = [[NSAlert alertWithMessageText:@"Unknown encrypted directory" defaultButton:@"Yes" alternateButton:@"No, decrypt permanently" otherButton:nil informativeTextWithFormat:@"The encrypted directory %@ is not known to Youcrypt (e.g., perhaps it has been moved or copied). Do you wish to register this encrypted directory with Youcrypt?", [path stringByDeletingLastPathComponent]] runModal];
            if (ret == NSAlertDefaultReturn) {
                [self openEncryptedFolder:path];
            } else if (ret == NSAlertAlternateReturn) {
                resQ.queueJob(cppString(path));
                found = 1;
            } else {
                return;
            }
        }
        
    }
    if (found) {
        dispatch_async(taskQ, ^{
            resQ.runTillEmpty();});
    }
}

- (BOOL)doRestore:(NSString *)path {    
    DirectoryMap &dmap = *(directories.get());
    std::string strPath([path cStringUsingEncoding:NSASCIIStringEncoding]);
    Folder d = dmap[strPath];
    if (!d)
        d = YCFolder::initFromScanningPath(strPath);
    
    switch (d->currStatus()) {
        case YoucryptDirectoryStatusUnknown:
        case YoucryptDirectoryStatusUninitialized:
        case YoucryptDirectoryStatusBadConfig:
            return NO;
        case YoucryptDirectoryStatusInitialized:
        case YoucryptDirectoryStatusNeedAuth:
            break;
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
    DirectoryMap &dmap = *(directories.get());
    std::string strPath([path cStringUsingEncoding:NSASCIIStringEncoding]);
    dmap.erase(strPath);
    
    if (listDirectories != nil) {
        [listDirectories.statusLabel setStringValue:@""];
        [listDirectories.progressIndicator stopAnimation:listDirectories.window];
        [listDirectories.progressIndicator setHidden:YES];
        [listDirectories.table reloadData];
    }
}

-(void) cancelRestore:(NSString *)path {
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
        return directories->size();
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
    
    DirectoryMap::iterator pos = directories->begin();
    for (int i=0; i<row; i++)
        ++pos;
    Folder dirAtRow = pos->second;
    if (!dirAtRow)
        return nil;
    
    //    [dirAtRow updateInfo];
    
    
    if ([colId isEqualToString:@"alias"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:nsstrFromCpp(dirAtRow->alias())];
        NSRange selectedRange = NSRangeFromString(nsstrFromCpp(dirAtRow->alias()));
        [str addAttribute:NSForegroundColorAttributeName
                    value:[NSColor blueColor]
                    range:selectedRange];
        [str addAttribute:NSUnderlineStyleAttributeName
                    value:[NSNumber numberWithInt:NSSingleUnderlineStyle]
                    range:selectedRange];
        
        return str;
    }
    else if ([colId isEqualToString:@"mountedPath"])
        return nsstrFromCpp(dirAtRow->mountedPath());
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
    
    DirectoryMap::iterator pos = directories->begin();
    for (int i=0; i<row; i++)
        ++pos;
    Folder dirAtRow = pos->second;
    if (!dirAtRow)
        return;
    
    //    [dirAtRow updateInfo];
    
    if (dirAtRow->currStatus() == YoucryptDirectoryStatusMounted)
    {
        // mounted => unlocked
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
            if (dirAtRow->currStatus() == YoucryptDirectoryStatusInitialized)
                [cell setImage:[NSImage imageNamed:@"box_closed_48x48.png"]];
            else if (dirAtRow->currStatus() == YoucryptDirectoryStatusBadConfig
                     || dirAtRow->currStatus() == YoucryptDirectoryStatusUnknown)
                [cell setImage:[NSImage imageNamed:@"error-22x22.png"]];
            if (dirAtRow->currStatus() == YoucryptDirectoryStatusProcessing)
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
        
        DirectoryMap::iterator pos = directories->begin();
        for (int i=0; i<rowIndex; i++)
            ++pos;
        Folder dir = pos->second;
        tooltip = [NSString stringWithFormat:@"Source folder: %@\n\n"
                   "Status: %@"
                   "%@", nsstrFromCpp(dir->rootPath()),
                   nsstrFromCpp(dir->stringStatus()),
                   ((dir->currStatus() == YoucryptDirectoryStatusMounted) ?
                    [NSString stringWithFormat:@"\n\nMounted at %@", nsstrFromCpp(dir->mountedPath())]
                    : @"")];
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
    if (listDirectories != nil)
        [listDirectories.table reloadData];
    return nil;
}

-(boost::shared_ptr<DirectoryMap>) getDirectories {
    if (!directories) {
        directories.reset(new DirectoryMap);
    }
    return directories;
}

-(boost::shared_ptr<UserAccount>) getUserAccount {
    if (!userAccount) {
        
        std::string userEmail = cppString([preferenceController getPreference:YC_USEREMAIL]);
        std::string userPW = cppString([passphraseManager getPassphrase]);
        userAccount.reset(new UserAccount(userEmail, userPW));
    }
    
    return userAccount;
}

@end

std::string cppString(NSString *s) {
    return std::string
    ([s cStringUsingEncoding:NSASCIIStringEncoding]);
}

NSString *nsstrFromCpp(std::string st) {
    NSString *s =
    [NSString stringWithCString:st.c_str()
                       encoding:NSASCIIStringEncoding];
    return s;
}




