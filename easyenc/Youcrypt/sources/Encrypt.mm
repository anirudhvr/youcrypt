//
//  Encrypt.mm
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
#import "core/Settings.h"

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
	if (!(self = [super initWithWindowNibName:@"Encrypt"])){
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
    NSDirectoryEnumerator *direnum = 
        [[NSFileManager defaultManager] enumeratorAtPath:srcFolder];
    
    int dirCount = 0;
    unsigned long long fileSize = 0;
    NSString *file;
    while(file = [direnum nextObject]) {
        fileSize += [[[NSFileManager defaultManager] 
                      attributesOfItemAtPath:file error:nil] fileSize];
        dirCount++;
    }
    DDLogInfo(@"Encrypting folder of size: %llu, #files: %d",fileSize, dirCount);
    
   // -- Figure out the password, sharing options, etc. --
    NSString *yourPasswordString =  nil;
    if (keychainHasPassphrase) {
        yourPasswordString = passphraseFromKeychain;
    } else {
        yourPasswordString = [yourPassword stringValue];
    }
        
    BOOL encfnames = NO;
    if ([[theApp.preferenceController getPreference:(MacUISettings::MacPreferenceKeys::yc_encryptfilenames)]
         intValue] != 0)
        encfnames = YES;
    youcrypt::YoucryptFolderOpts opts;
    if (encfnames == YES)
        opts.filenameEncryption = youcrypt::YoucryptFolderOpts::filenameEncrypt;
    else
        opts.filenameEncryption = youcrypt::YoucryptFolderOpts::filenamePlain;

    destFolder = [srcFolder stringByAppendingPathExtension:
                  ENCRYPTED_DIRECTORY_EXTENSION];

    dir = YCFolder::initEncryptedFolderInPlaceAddExtension(cppString(srcFolder), opts);
    
    if (dir.get() == NULL) {
        DDLogError(@"Encrypting directory in place failed!");
        return;
    }
    
    /* Hide directory extension of encrypted folder */
    {
        NSNumber *num = [NSNumber numberWithBool:YES];
        NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:num, NSFileExtensionHidden, nil];        
        [[NSFileManager defaultManager] setAttributes:attribs ofItemAtPath:destFolder error:nil];
    }
    
    // Send number of objects in directory to Mixpanel
    NSString *dirCountS = [NSString stringWithFormat:@"%d",dirCount];
    NSString *fileSizeS = [NSString stringWithFormat:@"%llu",fileSize];
#if 0
    if ([[theApp.preferenceController getPreference:(MacUISettings::MacPreferenceKeys::yc_anonymousstatistics)] intValue])
        [mixpanel track:nsstrFromCpp(appSettings()->mixPanelUUID)
             properties:[NSDictionary dictionaryWithObjectsAndKeys:
                         dirCountS, @"dirCount",
                         fileSizeS, @"dirSize",
                         nil]];
#endif
    
    [theApp didEncrypt:dir];
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
    dir.reset();
    [theApp cancelEncrypt:destFolder];
}



-(void)setPassphraseTextField:(NSString*)string
{
    if (string != nil) {
        [yourPassword setStringValue:string];
    }
}


@end
