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
    // 2.  Check if the last component is encrypted.yc
    // 3.  Check if it is already mounted
    // 4.  o/w, mount and open it.
    //--------------------------------------------------------------------------------------------------
    [self showDecryptWindow:self];
    return YES;
  
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






@end
