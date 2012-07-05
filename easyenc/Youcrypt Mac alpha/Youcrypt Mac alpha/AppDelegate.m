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
#import "libFunctions.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"
#import "CompressingLogFileManager.h"
#import "logging.h"
#import "ConfigDirectory.h"
#import "ListDirectoriesWindow.h"


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


// --------------------------------------------------------------------------------------
// App events
// --------------------------------------------------------------------------------------
- (id) init {
    self = [super init];
    
    configDir = [[ConfigDirectory alloc] init];
    youcryptService = [[YoucryptService alloc] init];
    //[youcryptService setApp:self];
    
    // TODO:  Load up directories array from the list file.
    directories = [NSKeyedUnarchiver unarchiveObjectWithFile:configDir.youCryptListFile];
    if (directories == nil) {
        directories = [[NSMutableArray alloc] init];
    }
    
    theApp = self;
    return self;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [NSKeyedArchiver archiveRootObject:directories toFile:configDir.youCryptListFile];
    
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
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"YC"];
    [statusItem setHighlightMode:YES];
    
    
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
    
    if(configDir.firstRun)
        [self showFirstRunSheet];
    
}
// --------------------------------------------------------------------------------------



// --------------------------------------------------------------------------------------
// Core Encrypt / Decrypt methods
// --------------------------------------------------------------------------------------
- (BOOL)openEncryptedFolder:(NSString *)path {   
    //--------------------------------------------------------------------------------------------------
    // 1.  Check if path is really a folder
    // 2.  Check if the last component is encrypted.yc   <---- TODO
    // 3.  Check if it is already mounted                <---- TODO
    // 4.  o/w, mount and open it.
    // 5.  Make sure we maintain it in our list.
    //--------------------------------------------------------------------------------------------------
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir && ([[path pathExtension] isEqualToString:@"yc"])) {
        
        // 1. Set up a new mount point
        // 2. Set up decrypt controller with the path and the mount point
        // 3. Open the decrypt window
        
        NSString *mountPoint = [[path stringByDeletingLastPathComponent] lastPathComponent];
        NSString *timeStr = [[NSDate date] descriptionWithCalendarFormat:nil timeZone:nil locale:nil];
        mountPoint = [configDir.youCryptVolDir stringByAppendingPathComponent:
                      [timeStr stringByAppendingPathComponent:mountPoint]];
        
        if (!decryptController) {
            decryptController = [[Decrypt alloc] init];
        }
        decryptController.destFolderPath = mountPoint;
        decryptController.sourceFolderPath = path;
        
        for (YoucryptDirectory *dir in directories) {
            if ([path isEqualToString:dir.path]) {
                dir.mountedPath = mountPoint;
                dir.mounted = NO;                
                goto FoundOne;
            }
        }
        {
            YoucryptDirectory *dir = [[YoucryptDirectory alloc] init];        
            dir.path = path;
            dir.mountedPath = mountPoint;
            dir.alias = [[path stringByDeletingLastPathComponent] lastPathComponent];
            dir.mounted = NO;
            [directories addObject:dir];            
        }
    FoundOne:        
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

- (void)didDecrypt:(NSString *)path {
    for (YoucryptDirectory *dir in directories) {
        if ([path isEqualToString:dir.path]) {
            dir.mounted = YES;
        }
    }
    if (listDirectories != nil) {
        [listDirectories.table reloadData];
    }
}
- (void)didEncrypt:(NSString *)path {
    YoucryptDirectory *dir = [[YoucryptDirectory alloc] init];        
    dir.path = [path stringByAppendingPathComponent:@"encrypted.yc"];
    dir.mountedPath = @"";
    dir.alias = [path lastPathComponent];
    dir.mounted = NO;
    [directories addObject:dir];            
    if (listDirectories != nil) {
        [listDirectories.table reloadData];
    }
}


- (IBAction)windowShouldClose:(id)sender {
    DDLogVerbose(@"Closing..");
}
- (IBAction)terminateApp:(id)sender {
    [NSApp terminate:nil];
}



// --------------------------------------------------------------------------------------
// Helper functions to show any window; you name it, we've it.
// --------------------------------------------------------------------------------------
- (IBAction)showMainApp:(id)sender {
    [self.window makeKeyAndOrderFront:self];
}
- (IBAction)showListDirectories:(id)sender {
    // Is list directories nil?
    if (!listDirectories) {
        listDirectories = [[ListDirectoriesWindow alloc] init];
    }
    [listDirectories showWindow:self];
}
- (IBAction)showPreferencePanel:(id)sender {
    // Is preferenceController nil?
    if (!preferenceController) {
        preferenceController = [[PreferenceController alloc] init];
    }
    DDLogVerbose(@"showing %@", preferenceController);
    [preferenceController showWindow:self];
}
- (void)showFirstRunSheet {
    // Is preferenceController nil?
    if (!preferenceController) {
        preferenceController = [[PreferenceController alloc] init];
    }
    DDLogVerbose(@"showing %@", preferenceController);
    [preferenceController showFirstRun]; 
    //[preferenceController showWindow:self];
}
- (IBAction)showDecryptWindow:(id)sender {
    // Is decryptController nil?
    if (!decryptController) {
        decryptController = [[Decrypt alloc] init];
    }
    DDLogVerbose(@"showing %@", decryptController);
    [decryptController showWindow:self];
}
- (IBAction)showEncryptWindow:(id)sender {
    // Is encryptController nil?
    if (!encryptController) {
        encryptController = [[Encrypt alloc] init];
    } else {
        /* other times, this code is called in awakefromNib */              
        if (encryptController.keychainHasPassphrase == NO) {
            encryptController.passphraseFromKeychain = [libFunctions getPassphraseFromKeychain:@"Youcrypt"];
            if (encryptController.passphraseFromKeychain != nil) {
                encryptController.keychainHasPassphrase = YES;
            }
        }
        NSString *passphrase =[libFunctions getPassphraseFromKeychain:@"Youcrypt"];
        if ([encryptController keychainHasPassphrase] == YES) {
            [encryptController setPassphraseTextField:passphrase];
        }
    }
    
    DDLogVerbose(@"showing %@", encryptController);
    [encryptController showWindow:self];
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
            // If it's a .yc file, we open it, otherwise, we encrypt it
            if ([[path pathExtension] isEqualToString:@"yc"]) {
                [theApp openEncryptedFolder:path];
            }
            else {
                [theApp encryptFolder:path];
            }
            [tableView reloadData];
            return YES;
        }
    }
    return NO;
}
                 



@end
