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
#import "FirstRunSheetController.h"
#import "FeedbackSheetController.h"


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
@synthesize firstRunSheetController;

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
    directories = [NSKeyedUnarchiver unarchiveObjectWithFile:configDir.youCryptListFile];
    if (directories == nil) {
        directories = [[NSMutableArray alloc] init];
    } else {
        
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
    
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications]; 
    int ycAppCount = 0;
    
    for(NSRunningApplication *app in apps) {
        if([[app localizedName] isEqualToString:@"Youcrypt Mac alpha"]) {
            ycAppCount++;
            if(ycAppCount > 1) {
                DDLogVerbose(@"FATAL. Cannot run multiple instances. Terminating!!");
                [self terminateApp:self];
            }
        }
    }

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
    NSImage *statusItemImage = [NSImage imageNamed:@"logo-color-alpha.png"];
    //[statusItem setTitle:@"YC"];
    [statusItem setImage:statusItemImage];
    [statusItem setMenu:statusMenu];
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
    
    if(configDir.firstRun) {
        NSLog(@"FIRST RUN ! ");
        [self showFirstRunSheet];
        
    }
        
    
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
        timeStr = [timeStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        mountPoint = [configDir.youCryptVolDir stringByAppendingPathComponent:
                      [timeStr stringByAppendingPathComponent:mountPoint]];
        
        if (!decryptController) {
            decryptController = [[Decrypt alloc] init];
        }
        decryptController.destFolderPath = mountPoint;
        decryptController.sourceFolderPath = path;
        
        YoucryptDirectory *dir;
        for (dir in directories) {
            if ([path isEqualToString:dir.path]) {
                if (dir.status == YoucryptDirectoryStatusUnmounted)
                    dir.mountedPath = mountPoint;
                goto FoundOne;
            }
        }        
        dir = [[YoucryptDirectory alloc] init];
        dir.path = path;
        dir.mountedPath = mountPoint;
        dir.alias = [[path stringByDeletingLastPathComponent] lastPathComponent];
        dir.status = YoucryptDirectoryStatusUnmounted;
        [directories addObject:dir];                
    FoundOne:      
        if (dir.status == YoucryptDirectoryStatusMounted == YES) {
            // Just need to open the folder in this case
            [[NSWorkspace sharedWorkspace] openFile:dir.mountedPath];	

        } else {
            [self showDecryptWindow:self];
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
            dir.status = YoucryptDirectoryStatusMounted;
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
    dir.status = YoucryptDirectoryStatusUnmounted;
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
    [self showFirstRun]; 
}

-(void)showFirstRun
{    
    NSLog(@"in show first run !");
    if(self.window == nil)
        NSLog(@"NIL WINDOW ____________ ");
    [firstRunSheetController beginSheetModalForWindow:theApp.listDirectories.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            NSLog(@"First run done");
            [self.window close];
        } else if (returnCode == kSheetReturnedCancel) {
            NSLog(@"First Run cancelled :( ");
        } else {
            NSLog(@"Unknown return code");
        }
    }];
    
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
    } 
    
    NSString *pp =[libFunctions getPassphraseFromKeychain:@"Youcrypt"];
    
    /* other times, this code is called in awakefromNib */              
    if (encryptController.keychainHasPassphrase == NO) {
        encryptController.passphraseFromKeychain = pp;
        if (encryptController.passphraseFromKeychain != nil) {
            encryptController.keychainHasPassphrase = YES;
        }
    } else {
        [encryptController setPassphraseTextField:pp];
    }
    
    DDLogVerbose(@"showing %@", encryptController);
    [encryptController showWindow:self];
}


- (IBAction)openFeedbackPage:(id)sender
{
    //[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://youcrypt.com"]];
    [feedbackSheetController beginSheetModalForWindow:theApp.listDirectories.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            NSLog(@"Feedback run done");
            [self.window close];
        } else if (returnCode == kSheetReturnedCancel) {
            NSLog(@"Feedback cancelled :( ");
        } else {
            NSLog(@"Unknown return code");
        }
    }];

}

- (IBAction)openHelpPage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://youcrypt.com"]];
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
   
    NSString *colId = [tableColumn identifier];
    
    if (!directories)
        return nil;
    
    YoucryptDirectory *dirAtRow = [directories objectAtIndex:row];
    if (!dirAtRow)
        return nil;
    
    NSMutableAttributedString *str = [NSMutableAttributedString alloc];
    
    if ([colId isEqualToString:@"alias"]) {
        [str initWithString:dirAtRow.alias];
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
            // If it's a .yc file, we open it, otherwise, we encrypt it
            if ([[path pathExtension] isEqualToString:@"yc"]) {
                [theApp openEncryptedFolder:path];
            }
            else if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:@"encrypted.yc"]
                              isDirectory:&isDir] && isDir) {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Decrypt?"
                                                 defaultButton:@"Decrypt"
                                               alternateButton:@"Cancel"
                                                   otherButton:nil
                                     informativeTextWithFormat:@"This folder already contains encrypted content.  Decrypt and open?"];
                if ([alert runModal] == NSAlertDefaultReturn) {
                    [theApp openEncryptedFolder:[path stringByAppendingPathComponent:@"encrypted.yc"]];
                    [tableView reloadData];
                    return YES;
                }              
                else {
                    return  NO;
                }
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

//--------------------------------------------------------------------------------------------------
// Code to color mounted and unmounted folders separately
//--------------------------------------------------------------------------------------------------
- (void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *colId = [tableColumn identifier];

 //  NSLog(@"This code called");
					
    if (!directories)
        return;
    
    YoucryptDirectory *dirAtRow = [directories objectAtIndex:row];
    if (!dirAtRow)
        return;
        
    [dirAtRow checkIfStillMounted];
    
    if (dirAtRow.status == YoucryptDirectoryStatusMounted) { // mounted => unlocked
        if ([cell isKindOfClass:[NSTextFieldCell class]]) {
            [cell setTextColor:[NSColor redColor]];
            [cell setBackgroundColor:[NSColor grayColor]];
        } else if ([cell isKindOfClass:[NSButtonCell class]] && [colId isEqualToString:@"status"]) {
            NSButtonCell *c = (NSButtonCell*) cell;
            [c setImage:[NSImage imageNamed:@"unlocked-24x24.png"]];
        }
    } else  { // unmounted => locked
        if ([cell isKindOfClass:[NSTextFieldCell class]]) {
            [cell setTextColor:[NSColor blackColor]];
            [cell setBackgroundColor:[NSColor darkGrayColor]];
        } else if ([cell isKindOfClass:[NSButtonCell class]] && [colId isEqualToString:@"status"]) {
            NSButtonCell *c = (NSButtonCell*) cell;
            if (dirAtRow.status == YoucryptDirectoryStatusUnmounted) 
                [c setImage:[NSImage imageNamed:@"locked-24x24.png"]];
            else if (dirAtRow.status == YoucryptDirectoryStatusError) 
                [c setImage:[NSImage imageNamed:@"error-22x22.png"]];
            if (dirAtRow.status == YoucryptDirectoryStatusProcessing)
                [c setImage:[NSImage imageNamed:@"logo-color-alpha.png"]];
        }
    }

 

}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
   // NSLog(@"This one too!");
    return nil;
}
   

@end
