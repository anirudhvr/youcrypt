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
#import "Contrib/SSKeychain/SSKeychain.h"
#import "AppDelegate.h"


@implementation Encrypt


@synthesize sourceFolderPath;
@synthesize destFolderPath;
@synthesize lastEncryptionStatus;
@synthesize encryptionInProcess;
@synthesize keychainHasPassphrase;
//@synthesize yourPassword;
@synthesize passphraseFromKeychain;


-(id)init
{
    keychainHasPassphrase = NO;
	if (![super initWithWindowNibName:@"Encrypt"]){
         return nil;
         DDLogVerbose(@"nil");
    }
    return self;
}

-(void)awakeFromNib
{
    [shareCheckBox setState:0];
    NSLog(@"Encrypt awake from nib called");
    
    
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
//    //[[NSWorkspace sharedWorkspace] setIcon:iconImage forFile:[sourceFolderPath stringByAppendingPathComponent:@"/encrypted.yc"] options:0];
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
- (IBAction)encrypt:(id)sender
{
    srcFolder = sourceFolderPath;
	/*** 
	 PREPARATIONS
	 A mkdir -p $HOME/easyenc/src 
	 B mkdir -p /tmp/easyenc/src
	 C cp -r src/ * /tmp/easyenc/src
	 D rm -rf src/ *
	 ***/
    //-       

	// The mount point is a temporary folder
    tempFolder = NSTemporaryDirectory();
    [libFunctions mkdirRecursive:tempFolder];
    testFolder = [tempFolder stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    tempFolder = [tempFolder stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    [libFunctions mkdirRecursive:tempFolder];
    [libFunctions mkdirRecursive:testFolder];

    // The destination of the encrypted files is just <sourcefolder>/encrypted.yc
    destFolder = [srcFolder stringByAppendingPathComponent:@"/encrypted.yc"];
    [libFunctions mkdirRecursive:destFolder];
    
    //FIXME:  Multiple folders

    
	/**** <!-- END PREP --> ***/

	// -------------------------- Figure out the password, sharing options, etc. ------------------------------------

    NSString *yourPasswordString =  nil;
    if (keychainHasPassphrase) {
        yourPasswordString = passphraseFromKeychain;
    } else {
        yourPasswordString = [yourPassword stringValue];
    }
        
	yourFriendsEmailString = [yourFriendsEmail stringValue];	
	
	// check if user wants to share with a friend
	if((yourFriendsEmailString != nil) && ![yourFriendsEmailString isEqualToString:@""]) {
		yourFriendsPassphrase = arc4random() % 100000000;
		yourFriendsPassphraseString = [NSString stringWithFormat:@"%d", yourFriendsPassphrase];
		combinedPasswordString = [NSString stringWithFormat:@"%@%@%d", yourPasswordString, @",", yourFriendsPassphrase];
		numberOfUsers = 2;
	} 
	else {
		// nope, no sharing
		combinedPasswordString = yourPasswordString;
		numberOfUsers = 1;
	}
    // ---------------------------------------------------------------------
	
    BOOL encfnames = NO;
    if ([[theApp.preferenceController getPreference:YC_ENCRYPTFILENAMES] intValue] != 0)
        encfnames = YES;
    
    NSNotificationCenter *nCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nCenter removeObserver:self];
    [nCenter addObserver:self selector:@selector(didMount:) name:NSWorkspaceDidMountNotification object:nil];
     

    if (![libFunctions createEncFS:destFolder decryptedFolder:tempFolder numUsers:numberOfUsers combinedPassword:combinedPasswordString encryptFilenames:encfnames]) {
        // Error while encrypting.
        // TODO.        
    }
    
    // Try to overlay icon !!
    return;
}


-(IBAction)didMount:(id)sender {
    BOOL errOccurred = NO;
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    
    
    // Now to move the contents of tempFolder into destFolder
    // Unfortunately, a direct move won't work since both directories exist and
    // macOS thinks it is overwriting the mount point we just created
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:srcFolder error:nil];
    for (NSString *file in files) {
        if (![file isEqualToString:@"encrypted.yc"]) {
            NSError *err;
            NSString *srcPath, *destPath;
            
            srcPath = [srcFolder stringByAppendingPathComponent:file];
            destPath = [tempFolder stringByAppendingPathComponent:file];
            
            if (![fm copyItemAtPath:srcPath toPath:destPath error:&err]) {
                [[NSAlert alertWithError:err] runModal];
                errOccurred = YES;
                goto Cleanup;
            }
            if (![fm contentsEqualAtPath:srcPath andPath:destPath]) {
                [[NSAlert alertWithMessageText:@"Error while encrypting" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Error while encrypting file %@.  Aborting the operation.", srcPath] runModal];
                errOccurred = YES;
                goto Cleanup;
            }            
        }
    }

    // Can safely delete the files.
    BOOL displayErr = NO;
    for (NSString *file in files) {
        if (![file isEqualToString:@"encrypted.yc"]) {
            if (![fm removeItemAtPath:[srcFolder stringByAppendingPathComponent:file] error:nil]) {
                displayErr = YES;
            }
        }
    }
    if (displayErr) {
        [[NSAlert alertWithMessageText:@"Error while cleaning" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"There was an error while deleting some files after encrypting.  Please remove them manually from %@ .\nEncrypted content is at %@", srcFolder, destFolder] runModal];
    }    
Cleanup:    

    // Unmount the destination folder containing decrypted files
    [libFunctions execCommand:@"/sbin/umount" arguments:[NSArray arrayWithObject:tempFolder]
                          env:nil];
    [fm removeItemAtPath:tempFolder error:nil];
    
    if (errOccurred == NO) {
        // Now move stuff out of the destFolder onto the parent directory.
        NSString *file;
        for (file in [fm contentsOfDirectoryAtPath:destFolder error:nil]) {
            [fm moveItemAtPath:[destFolder stringByAppendingPathComponent:file] 
                        toPath:[srcFolder stringByAppendingPathComponent:file] 
                         error:nil];
        }
        [fm removeItemAtPath:destFolder error:nil];
        
        destFolder = [srcFolder stringByAppendingPathExtension:@"yc"];        
        [fm moveItemAtPath:srcFolder toPath:destFolder error:nil];
            
        /* change folder icon of encrypted folder */
        {
            NSNumber *num = [NSNumber numberWithBool:YES];
            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:num, NSFileExtensionHidden, nil];        
            [[NSFileManager defaultManager] setAttributes:attribs ofItemAtPath:destFolder error:nil];
        }
        
        [theApp didEncrypt:destFolder];
        /* Register password with keyring */
        
        /*** <!-- ENCFS END --> ***/
        /* If sharing is required */
//        if (numberOfUsers == 2) {
//            
//            /***** MAILGUN TASK START ******/
//            
//            NSString *curlEmail = [NSString stringWithFormat:@"to=\"%@\"", yourFriendsEmailString];
//            NSString *curlKey   = [NSString stringWithFormat:@"text=\%@\"", yourFriendsPassphraseString];
//            
//            [libFunctions execCommand:@"/usr/bin/curl" 
//                            arguments:[NSArray arrayWithObjects: 
//                                       @"-s", @"-k", 
//                                       @"--user", @"api:key-67fgovcfrggd6y4l02ucpz-av4b22i26",
//                                       @"https://api.mailgun.net/v2/cloudclear.mailgun.org/messages",
//                                       @"-F", @"from='YouCrypt <postmaster@cloudclear.mailgun.org>'",
//                                       @"-F", curlEmail,
//                                       @"-F", @"subject='Your Temporary Passphrase'",
//                                       @"-F", curlKey,
//                                       nil]
//                                  env:nil];
//            /***** <!-- MAILGUN END --> ******/
//        }
    }             
    [yourPassword setStringValue:@""];
    [yourFriendsEmail setStringValue:@""];
    [self.window close];

}

-(IBAction)cancel:(id)sender {
    [self.window close];
}



-(void)setPassphraseTextField:(NSString*)string
{
    if (string != nil) {
        [yourPassword setStringValue:string];
    }
}


@end
