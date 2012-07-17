//
//  AppDelegate.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
#import "TourController.h"
#import "CompressingLogFileManager.h"
#import "TourWizard.h"
#import "DBLinkedView.h"
#import "MixpanelAPI.h"
#import "AboutController.h"

#define MIXPANEL_TOKEN @"b01b99df347adcb20353ba2a4cb6faf4" // avr@nouvou.com's token
int ddLogLevel = LOG_LEVEL_VERBOSE;


/* Global Variables Accessible to everyone */
/* These variables should be initialized */
AppDelegate *theApp;
CompressingLogFileManager *logFileManager;
MixpanelAPI *mixpanel;

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
@synthesize tourController;
@synthesize tourWizard;
@synthesize fileLogger;
@synthesize dropboxEncryptedFolders;
@synthesize mixpanelUUID;
@synthesize aboutController;

// --------------------------------------------------------------------------------------
// App events
// --------------------------------------------------------------------------------------
- (id) init {
    self = [super init];
    
    configDir = [[ConfigDirectory alloc] init];
    youcryptService = [[YoucryptService alloc] init];
    firstRunSheetController = [[FirstRunSheetController alloc] init];
    feedbackSheetController = [[FeedbackSheetController alloc] init];
    
    //[youcryptService setApp:self];
    
    // TODO:  Load up directories array from the list file.
    directories = [libFunctions unarchiveDirectoryListFromFile:configDir.youCryptListFile];
    if (directories == nil) {
        directories = [[NSMutableArray alloc] init];
    } else {
        // Do stuff here to check if dirs are all 
    }
    
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
    
    return self;
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
    for (dir in directories) {
        if (dir.status == YoucryptDirectoryStatusProcessing)
            dir.status = YoucryptDirectoryStatusSourceNotFound;
    }
    
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(someUnMount:) name:NSWorkspaceDidUnmountNotification object:nil];
    [self someUnMount:nil];

    DDLogVerbose(@"App did, in fact, finish launching!!!");
//    NSDictionary *env = [[NSProcessInfo processInfo] environment];
   
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    //[NSKeyedArchiver archiveRootObject:directories toFile:configDir.youCryptListFile];
    [libFunctions archiveDirectoryList:directories toFile:configDir.youCryptListFile];
    for (id dir in directories) {
       
        [libFunctions execCommand:@"/sbin/umount" arguments:[NSArray arrayWithObject:[dir mountedPath]]
                              env:nil];
    }
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {    
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
    
    
    if(configDir.firstRun) {
        //[self showListDirectories:self];
        DDLogInfo(@"Initiating First Run! ");
        //[self showFirstRunSheet];
        [self showTour];
    }    
}
// --------------------------------------------------------------------------------------



// --------------------------------------------------------------------------------------
// Core Encrypt / Decrypt methods
// --------------------------------------------------------------------------------------
- (BOOL)openEncryptedFolder:(NSString *)path {   
    //--------------------------------------------------------------------------------------------------
    // 1.  Check if path is really a folder
    // 4.  o/w, mount and open it.
    // 5.  Make sure we maintain it in our list.
    //--------------------------------------------------------------------------------------------------
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir && ([[path pathExtension] isEqualToString:@"yc"])) {
        
        // 1. Set up a new mount point
        // 2. Set up decrypt controller with the path and the mount point
        // 3. Open the decrypt window
        
        NSString *mountPoint = [[path stringByDeletingPathExtension] lastPathComponent];
        NSString *timeStr = [[NSDate date] descriptionWithCalendarFormat:nil timeZone:nil locale:nil];
        timeStr = [timeStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        mountPoint = [configDir.youCryptVolDir stringByAppendingPathComponent:
                      [timeStr stringByAppendingPathComponent:mountPoint]];
        
        
        YoucryptDirectory *dir;
        for (dir in directories) {
            if ([path isEqualToString:dir.path]) {
                if (dir.status == YoucryptDirectoryStatusUnmounted) {
                    dir.status =  YoucryptDirectoryStatusProcessing;
                    dir.mountedPath = mountPoint;
                }
                goto FoundOne;
            }
        }        
        dir = [[YoucryptDirectory alloc] init];
        dir.path = path;
        dir.alias = [[path stringByDeletingPathExtension] lastPathComponent];
//        dir.status = YoucryptDirectoryStatusUnmounted;
        dir.status = YoucryptDirectoryStatusProcessing;
        dir.mountedPath = mountPoint;
        [directories addObject:dir];                
    FoundOne:      
        [dir checkYoucryptDirectoryStatus:YES]; // Check that it's actually mounted.

        NSString *source = [NSString stringWithFormat:@"tell application \"Finder\"\n"
                            "set selectedItems to selection\n"
                            "if ((count of selectedItems) > 0) then\n"
                            "set selectedItem to ((item 1 of selectedItems) as alias)\n"
                            "POSIX path of selectedItem\n"
                            "end if\n"
                            "end tell\n"];
        NSAppleScript *update=[[NSAppleScript alloc] initWithSource:source];
        NSDictionary *err;
        NSAppleEventDescriptor *ret = [update executeAndReturnError:&err];
        NSString *finderSelPath = [ret stringValue];
        NSString *finderPath;
        
        source = [NSString stringWithFormat:@"tell application \"Finder\"\n"
                  "set selectedItems to selection\n"
                  "POSIX path of (target of Finder window 1 as alias)\n"
                  "end tell\n"];
        update = [[NSAppleScript alloc] initWithSource:source];
        ret = [update executeAndReturnError:&err];
        finderPath = [ret stringValue];
        
        if (((finderPath != nil) && ([finderPath isEqualToString:[[dir.path stringByDeletingLastPathComponent] stringByAppendingFormat:@"/"]]))
            || ((finderPath != nil) && ([finderSelPath isEqualToString:[dir.path stringByAppendingFormat:@"/"]])))
            callFinderScript = YES;
        else {
            callFinderScript = NO;
        }
            

        if (dir.status == YoucryptDirectoryStatusMounted) {
            // Just need to open the folder in this case  
            if (callFinderScript == NO) {
                [[NSWorkspace sharedWorkspace] openFile:dir.mountedPath];	
            }
            else {
                
                NSString *source=[NSString stringWithFormat:@"tell application \"Finder\"\n"
                                  "activate\n"
                                  "set target of Finder window 1 to disk \"%@\"\n"
                                  "set current view of Finder window 1 to icon view\n"
                                  "end tell\n", dir.alias];
                NSAppleScript *update=[[NSAppleScript alloc] initWithSource:source];
                NSDictionary *err;
                NSAppleEventDescriptor *ret = [update executeAndReturnError:&err];
                DDLogInfo(@"AppleScript return : %@",ret);
                if (err != nil)
                    [[NSWorkspace sharedWorkspace] openFile:dir.mountedPath];
            }
        } else {
            dir.status = YoucryptDirectoryStatusProcessing;
            dir.mountedPath = mountPoint;
            
            // Check if the keychain contains a password.
            
            [self showDecryptWindow:self path:dir.path mountPoint:mountPoint];
        }
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
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        [self showEncryptWindow:self path:path];
    }
}

- (void)didDecrypt:(NSString *)path {
    for (YoucryptDirectory *dir in directories) {
        if ([path isEqualToString:dir.path]) {
            dir.status = YoucryptDirectoryStatusMounted;
            if (callFinderScript == NO) {
                [[NSWorkspace sharedWorkspace] openFile:dir.mountedPath];	
            }
            else {
                
                NSString *source=[NSString stringWithFormat:@"tell application \"Finder\"\n"
                                  "activate\n"
                                  "set target of Finder window 1 to disk \"%@\"\n"
                                  "set current view of Finder window 1 to icon view\n"
                                  "end tell\n", dir.alias];
                NSAppleScript *update=[[NSAppleScript alloc] initWithSource:source];
                NSDictionary *err;
                NSAppleEventDescriptor *ret = [update executeAndReturnError:&err];
                if (err != nil)
                    [[NSWorkspace sharedWorkspace] openFile:dir.mountedPath];
            }
            DDLogVerbose(@"didDecrypt folder %@\n", path);

//            [dir checkYoucryptDirectoryStatus:YES];
        }
    }

    if (listDirectories != nil) {
        [listDirectories.table reloadData];
    }
}

- (void)didEncrypt:(NSString *)path {
    NSImage *overlay = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/youcrypt-overlay.icns"]];
    BOOL didSetIcon = [[NSWorkspace sharedWorkspace] setIcon:overlay forFile:path options:0];
    if(!didSetIcon)
        DDLogInfo(@"ERROR: Could not set Icon for %@",path);
    
    YoucryptDirectory *dir = [[YoucryptDirectory alloc] init];       
    dir.path = path;
    dir.mountedPath = @"";
    dir.alias = [[path stringByDeletingPathExtension] lastPathComponent];
    dir.status = YoucryptDirectoryStatusUnmounted;
    [directories addObject:dir];            
    if (listDirectories != nil) {
        [listDirectories.table reloadData];
    }
}

- (void)didRestore:(NSString *)path {
    for (YoucryptDirectory *dir in directories) {
        if ([path isEqualToString:dir.path]) {
            [directories removeObject:dir];
            break;
        }
        
    }
    if (listDirectories != nil) {
        [listDirectories.table reloadData];
    }
}

-(void) cancelRestore:(NSString *)path {
    for (YoucryptDirectory *dir in directories) {
        if ([path isEqualToString:dir.path]) {
            dir.status = YoucryptDirectoryStatusUnmounted; // Should've been processing
            [dir updateInfo];
            break;
        }
        
    }    
}

-(void) cancelDecrypt:(NSString *)path {
    for (YoucryptDirectory *dir in directories) {
        if ([path isEqualToString:dir.path]) {
            dir.status = YoucryptDirectoryStatusUnmounted; // Should've been processing
            [dir updateInfo];
            break;
        }
        
    }    
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
    [listDirectories.window makeKeyAndOrderFront:self];
}

- (IBAction)showListDirectories:(id)sender {
    // Is list directories nil?
    if (!listDirectories) {
        listDirectories = [[ListDirectoriesWindow alloc] init];
    }
    [listDirectories.window makeKeyAndOrderFront:self];
    [listDirectories showWindow:self];
}

- (IBAction)showPreferencePanel:(id)sender {
    // Is preferenceController nil?
    if (!preferenceController) {
        preferenceController = [[PreferenceController alloc] init];
    }
    [preferenceController showWindow:self];
}

- (void)showFirstRunSheet {
    // Is preferenceController nil?
    if (!preferenceController) {
        preferenceController = [[PreferenceController alloc] init];
    }
    [self showFirstRun]; 
    
}

- (IBAction)showAboutWindow:(id)sender
{
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
    
    DDLogVerbose(@"Now showing tourController: %@", tourController);
    [tourWizard showWindow:self];
}

-(void)showFirstRun
{    
    DDLogInfo(@"About to First Run! !");
    if(self.window == nil)
        DDLogVerbose(@"ERROR: In First Run, NIL WINDOW ");
    [self showListDirectories:self];
    [firstRunSheetController beginSheetModalForWindow:theApp.listDirectories.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            DDLogVerbose(@"FirstRunSheet: Done");
            [self.window close];
        } else if (returnCode == kSheetReturnedCancel) {
            DDLogVerbose(@"FirstRunSheet: cancelled :( ");
        } else {
            DDLogVerbose(@"FirstRunSheet: Unknown return code");
        }
    }];    
}


- (IBAction)showDecryptWindow:(id)sender path:(NSString *)path mountPoint:(NSString *)mountPath {
    // Is decryptController nil?
    if (!decryptController) {
        decryptController = [[Decrypt alloc] init];
    }
    
    decryptController.sourceFolderPath = path;
    decryptController.destFolderPath = mountPath;
        
    NSString *pp =[libFunctions getPassphraseFromKeychain:@"Youcrypt"];
    DDLogInfo(@"showing %@", decryptController);
    
    if ((pp != nil) && !([pp isEqualToString:@""])) {
        DDLogVerbose(@"In showDecryptWindow: Got pp from keychain successfully");
        decryptController.passphraseFromKeychain = pp;
        decryptController.keychainHasPassphrase = YES;
        [decryptController decrypt:self];
    }
    else {
        decryptController.keychainHasPassphrase = NO;
        [decryptController showWindow:self];
    }
}

- (IBAction)showRestoreWindow:(id)sender path:(NSString *)path {
    if (!restoreController) {
        restoreController = [[RestoreController alloc] init];
    }

    restoreController.path = path;
    NSString *pp =[libFunctions getPassphraseFromKeychain:@"Youcrypt"];
    if (pp != nil && !([pp isEqualToString:@""])) {
        DDLogVerbose(@"In showRestoreWindow: Got pp from keychain successfully");
        restoreController.passwd = pp;
        restoreController.keychainHasPassphrase = YES;
        [restoreController restore:self];
    }
    else {
        restoreController.keychainHasPassphrase = NO;
        [restoreController showWindow:self];
    }
}


- (IBAction)showEncryptWindow:(id)sender path:(NSString *)path {
    // Is encryptController nil?
    if (!encryptController) {
        encryptController = [[Encrypt alloc] init];
    } 
    
    NSString *pp =[libFunctions getPassphraseFromKeychain:@"Youcrypt"];
    encryptController.sourceFolderPath = path;
    if (pp != nil && [pp isNotEqualTo:@""]) {
        DDLogVerbose(@"In showEncryptWindow: Got pp from keychain successfully");
        encryptController.passphraseFromKeychain = pp;
        encryptController.keychainHasPassphrase = YES;
        [encryptController encrypt:self];
    } else { 
        encryptController.passphraseFromKeychain = nil;
        encryptController.keychainHasPassphrase = NO;
        [encryptController showWindow:self];
        
    }
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
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://youcrypt.com"]];
}

- (void) encryptDropboxFolders
{
    DDLogVerbose(@"In encryptDropboxFolders: list of DB Encrypted Folders %@",dropboxEncryptedFolders);
    NSArray *folders = [dropboxEncryptedFolders allObjects];
    if(folders || folders.count) {
        [self encryptFolders:folders];
    }
}

- (void) encryptFolders:(NSArray *)folders
{
    if (!encryptController) {
        encryptController = [[Encrypt alloc] init];
    } 
    NSString *pp =[libFunctions getPassphraseFromKeychain:@"Youcrypt"];
    encryptController.passphraseFromKeychain = pp;
    encryptController.keychainHasPassphrase = YES;
    NSString *path;
    for (int i=0; i<folders.count; i++) {
        path = [folders objectAtIndex:i];
        DDLogVerbose(@"encryptFolders: Encrypting Folder %d : %@",i+1,path);
        [tourWizard.currentView.message setStringValue:[NSString stringWithFormat:@"Updating %d%%",((i+1)*100)/folders.count]];
        encryptController.sourceFolderPath = path;
        [encryptController encrypt:self];

    }
    [tourWizard.currentView.message setStringValue:@"Done."];
    /*
    for (NSString *path in folders) {
        NSLog(@"Encrypting DB Folder %@",path);
        encryptController.sourceFolderPath = path;
        [encryptController encrypt:self];
    } 
     */
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
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {  
            
            //FIXME:  If it's a .yc file but not in our list file.
            
            // If it's a .yc file, we open it, otherwise, we encrypt it
            if ([[path pathExtension] isEqualToString:@"yc"]) {
                [theApp openEncryptedFolder:path];
            }
//            else if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:@"encrypted.yc"]
//                              isDirectory:&isDir] && isDir) {
//                NSAlert *alert = [NSAlert alertWithMessageText:@"Decrypt?"
//                                                 defaultButton:@"Decrypt"
//                                               alternateButton:@"Cancel"
//                                                   otherButton:nil
//                                     informativeTextWithFormat:@"This folder already contains encrypted content.  Decrypt and open?"];
//                if ([alert runModal] == NSAlertDefaultReturn) {
//                    [theApp openEncryptedFolder:[path stringByAppendingPathComponent:@"encrypted.yc"]];
//                    return YES;
//                }              
//                else {
//                    return  NO;
//                }
//            }                                           
            else {
                [theApp encryptFolder:path];
            }
            return YES;
        }
    }
    return NO;
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
    
    if (dirAtRow.status == YoucryptDirectoryStatusMounted) { // mounted => unlocked
        if ([cell isKindOfClass:[NSTextFieldCell class]]) {
            [cell setTextColor:[NSColor redColor]];
            [cell setBackgroundColor:[NSColor grayColor]];
        } else if ([cell isKindOfClass:[NSButtonCell class]] && [colId isEqualToString:@"status"]) {
            [cell setImage:[NSImage imageNamed:@"box_open_48x48.png"]];
        } else if ([cell isKindOfClass:[NSPopUpButtonCell class]] && [colId isEqualToString:@"props"]) {
            /*NSPopUpButtonCell *dataTypeDropDownCell = [tableColumn dataCell];
            [[dataTypeDropDownCell itemAtIndex:1] setTitle:@"Close"];*/
            [[[tableColumn dataCell] itemAtIndex:2] setHidden:NO];
        }
    } else  { // unmounted => locked
        if ([cell isKindOfClass:[NSTextFieldCell class]]) {
            [cell setTextColor:[NSColor blackColor]];
            [cell setBackgroundColor:[NSColor darkGrayColor]];
            
        } else if ([cell isKindOfClass:[NSButtonCell class]] && [colId isEqualToString:@"status"]) {
            if (dirAtRow.status == YoucryptDirectoryStatusUnmounted) 
                [cell setImage:[NSImage imageNamed:@"box_closed_48x48.png"]];
            else if (dirAtRow.status == YoucryptDirectoryStatusSourceNotFound) 
                [cell setImage:[NSImage imageNamed:@"error-22x22.png"]];
            if (dirAtRow.status == YoucryptDirectoryStatusProcessing)
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
                             "%@", dir.path, [YoucryptDirectory statusToString:dir.status],
                             (dir.status == YoucryptDirectoryStatusMounted ? [NSString stringWithFormat:@"\n\nMounted at %@", dir.mountedPath] : @"")];
    } else {
        tooltip = [NSString stringWithString:@"Drag folders here to encrypt them with YouCrypt"];
    }

    return tooltip;
}

- (void) removeFSAtRow:(int) row {
    YoucryptDirectory *dir = [directories objectAtIndex:row];
    [self showRestoreWindow:self path:dir.path];
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
    [YoucryptDirectory refreshMountedFuseVolumes];
    YoucryptDirectory *dir;
    for (dir in directories) {
        [dir updateInfo];
    }
    if (listDirectories != nil)
        [listDirectories.table reloadData];
    return nil;
}


@end
