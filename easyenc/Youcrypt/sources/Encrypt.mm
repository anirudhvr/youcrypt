//
//  SpeakLineAppDelegate.m
//  SpeakLine
//
//  Created by Anirudh Ramachandran on 6/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Encrypt.h"
#import "PreferenceController.h"
#import "libFunctions.h"
#import "logging.h"
#import "AppDelegate.h"
#import "PassphraseManager.h"
#import "MixpanelAPI.h"
#import "YoucryptDirectory.h"

@implementation Encrypt


@synthesize sourceFolderPath;
@synthesize destFolderPath;
@synthesize lastEncryptionStatus;
@synthesize encryptionInProcess;
@synthesize keychainHasPassphrase;
@synthesize checkStorePasswd;
@synthesize dir;
@synthesize passphraseFromKeychain;


-(id)init
{
    keychainHasPassphrase = NO;
	if (![super initWithWindowNibName:@"Encrypt"]){
         return nil;
         DDLogVerbose(@"ERROR: encryptController is NIL in Encrypt.m");
    }
    return self;
}

-(void)awakeFromNib
{
    [shareCheckBox setState:0];
    
}

- (IBAction)encrypt:(id)sender
{
    srcFolder = sourceFolderPath;
    
    // Enumerate DIR contents to get number of objects in dir
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:srcFolder];
    
    int dirCount = 0;
    unsigned long long fileSize = 0;
    NSString *file;
    while(file = [direnum nextObject]) {
        fileSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil] fileSize];
        dirCount++;
    }
    DDLogInfo(@"Encrypting folder of size: %llu, #files: %d",fileSize, dirCount);
    
	// -------------------------- Figure out the password, sharing options, etc. ------------------------------------

    NSString *yourPasswordString =  nil;
    if (keychainHasPassphrase) {
        yourPasswordString = passphraseFromKeychain;
    } else {
        yourPasswordString = [yourPassword stringValue];
    }
        
    
    BOOL encfnames = NO;
    if ([[theApp.preferenceController getPreference:YC_ENCRYPTFILENAMES] intValue] != 0)
        encfnames = YES;
    
    dir = [[YoucryptDirectory alloc] initWithPath:srcFolder];
    if ([dir status] != YoucryptDirectoryStatusUnknown) {
        DDLogError(@"Directory to be encrypted looks like something else; status %@", [dir getStatus]);
        return ;
    }
    
    if (![dir encryptFolderInPlaceWithPassphrase:yourPasswordString encryptFilenames:encfnames]) {
        DDLogInfo(@"Encrypt error");
        return ;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    destFolder = [srcFolder stringByAppendingPathExtension:ENCRYPTED_DIRECTORY_EXTENSION];
    if (![fm moveItemAtPath:srcFolder toPath:destFolder error:&err]) {
        DDLogError(@"Encrypt: cannot move items at %@ to %@", srcFolder, destFolder);
        return;
    }
    
    /* change folder icon of encrypted folder */
    {
        NSNumber *num = [NSNumber numberWithBool:YES];
        NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:num, NSFileExtensionHidden, nil];        
        [[NSFileManager defaultManager] setAttributes:attribs ofItemAtPath:destFolder error:nil];
    }
    
    // Send number of objects in directory
    NSString *dirCountS = [NSString stringWithFormat:@"%d",dirCount];
    NSString *fileSizeS = [NSString stringWithFormat:@"%llu",fileSize];
    if ([[theApp.preferenceController getPreference:YC_ANONYMOUSSTATISTICS] intValue])
        [mixpanel track:theApp.mixpanelUUID
             properties:[NSDictionary dictionaryWithObjectsAndKeys:
                         dirCountS, @"dirCount",
                         fileSizeS, @"dirSize",
                         nil]];
    
    [self.window close];
    dir.path = destFolder;
    [theApp didEncrypt:dir];
    
    return;
}



- (IBAction)startIt:(id)sender {
    [encryptProgress setHidden:NO];
    //Create the block that we wish to run on a different thread.
    void (^progressBlock)(void);
    progressBlock = ^{
        [encryptProgress setIndeterminate:NO];
        [encryptProgress setDoubleValue:0.0];
        [encryptProgress startAnimation:sender];
        BOOL running = YES; // this is a instance variable
        int processAmount = 10000;
        int i = 0;
        while (running) {
            if (i++ >= processAmount) { // processAmount is something like 1000000
                running = NO;
                continue;
            }
            
            // Update progress bar
            double progr = (double)i / (double)processAmount;
            progr *=100;
            DDLogVerbose(@"progr: %f", progr); // Logs values between 0.0 and 1.0
            
            //NOTE: It is important to let all UI updates occur on the main thread,
            //so we put the following UI updates on the main queue.
            dispatch_async(dispatch_get_main_queue(), ^{
                [encryptProgress setDoubleValue:progr];
                [encryptProgress setNeedsDisplay:YES];
            });
            
            // Do some more hard work here...
        }
        
    }; //end of progressBlock
    
    //Finally, run the block on a different thread.
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    dispatch_async(queue,progressBlock);
}

/* Expand window to show sharing functionality */
-(IBAction)shareCheckClicked:(id)sender
{
    NSRect myRect;
    NSPoint sourcePoint = [self.window frame].origin;
    if([shareCheckBox state] == 1){
        myRect = NSMakeRect(sourcePoint.x,sourcePoint.y,354,266);
        [self.window setFrame:myRect display:YES animate:YES];
    } else {
        myRect = NSMakeRect(sourcePoint.x,sourcePoint.y,177,266);
        [self.window setFrame:myRect display:YES animate:YES];
    }
}

/* Change Folder Icon */
- (IBAction)setFolderIcon:(id)sender
{
//    NSString *curDir = [[NSFileManager defaultManager] currentDirectoryPath];
    return;
//    NSString *bundlepath =[[NSBundle mainBundle] resourcePath];
//    NSString *iconPath = [bundlepath stringByAppendingPathComponent:@"/lockedfolder2.icns"]; 
//    NSImage* iconImage = [[NSImage alloc] initWithContentsOfFile:iconPath];
//    BOOL didSetIcon = NO;
//    //[[NSWorkspace sharedWorkspace] setIcon:iconImage forFile:[sourceFolderPath stringByAppendingPathComponent:ENCRYPTION_TEMPORARY_FOLDER] options:0];
//
//    if(didSetIcon)
//        DDLogVerbose(@"Set Folder icon");
//    else
//        DDLogVerbose(@"Could not set Folder Icon");
}

/**
 
 apply
 
 Captures the action of the Apply button in Encrypt window.
 
 sender: window who sent the action
 
 **/



-(IBAction)cancel:(id)sender {
    [self.window close];
    dir = nil;
    [theApp cancelEncrypt:destFolder];
}



-(void)setPassphraseTextField:(NSString*)string
{
    if (string != nil) {
        [yourPassword setStringValue:string];
    }
}


@end