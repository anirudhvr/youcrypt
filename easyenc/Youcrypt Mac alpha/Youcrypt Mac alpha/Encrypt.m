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
#import "SSKeychain.h"


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
    [self setFolderIcon:self];
    [shareCheckBox setState:0];
    NSLog(@"Awake from nib called");
    
    if (keychainHasPassphrase == NO) {
        passphraseFromKeychain = [libFunctions getPassphraseFromKeychain];
        if (passphraseFromKeychain == nil) {
            keychainHasPassphrase = NO;
        } else {
            keychainHasPassphrase = YES;
            [yourPassword setStringValue:passphraseFromKeychain];
        }
    }
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
    NSString *bundlepath =[[NSBundle mainBundle] resourcePath];
    NSString *iconPath = [bundlepath stringByAppendingPathComponent:@"/lockedfolder2.icns"]; 
    NSImage* iconImage = [[NSImage alloc] initWithContentsOfFile:iconPath];
    BOOL didSetIcon = [[NSWorkspace sharedWorkspace] setIcon:iconImage forFile:[sourceFolderPath stringByAppendingPathComponent:@"/encrypted.yc"] options:0];

    if(didSetIcon)
        DDLogVerbose(@"DONE :) ");
    else
        DDLogVerbose(@" :( ");
    
}

/**
 
 apply
 
 Captures the action of the Apply button in Encrypt window.
 
 sender: window who sent the action
 
 **/
- (IBAction)encrypt:(id)sender
{
    NSString *srcFolder = sourceFolderPath;
    NSString *destFolder;
	/*** 
	 PREPARATIONS
	 A mkdir -p $HOME/easyenc/src 
	 B mkdir -p /tmp/easyenc/src
	 C cp -r src/ * /tmp/easyenc/src
	 D rm -rf src/ *
	 ***/
    //-       

	// The mount point is a temporary folder
    NSString *tempFolder = NSTemporaryDirectory();
    tempFolder = [tempFolder stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    [libFunctions mkdirRecursive:tempFolder];

    // The destination of the encrypted files is just <sourcefolder>/encrypted.yc
    destFolder = [srcFolder stringByAppendingPathComponent:@"/encrypted.yc"];
    [libFunctions mkdirRecursive:destFolder];

    
	/**** <!-- END PREP --> ***/

	// ---- Figure out the password, sharing options, etc. -----------------
    NSString *yourPasswordString = [yourPassword stringValue];    
    if (!keychainHasPassphrase) {
        [libFunctions registerWithKeychain:yourPasswordString];
        keychainHasPassphrase = YES;
    }
        
	NSString *yourFriendsEmailString = [yourFriendsEmail stringValue];	
	NSString *combinedPasswordString;
	int numberOfUsers;
	int yourFriendsPassphrase;	
	NSString *yourFriendsPassphraseString;
	
	// check if user wants to share with a friend
	if(![yourFriendsEmailString isEqualToString:@""]) {
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
	
    [libFunctions createEncFS:destFolder decryptedFolder:tempFolder numUsers:numberOfUsers combinedPassword:combinedPasswordString];
    
    
    // Now to move the contents of tempFolder into destFolder
    // Unfortunately, a direct move won't work since both directories exist and
    // stupid macOS thinks it is overwriting the mount point we just created
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:srcFolder error:nil];
    for (NSString *file in files) {
        if (![file isEqualToString:@"encrypted.yc"]) {
            [fm moveItemAtPath:[srcFolder stringByAppendingPathComponent:file] toPath:[tempFolder stringByAppendingPathComponent:file] error:nil];
        }
    }

    // Unmount the destination folder containing decrypted files
    [libFunctions execWithSocket:@"/sbin/umount" arguments:[NSArray arrayWithObject:tempFolder]
                             env:nil io:nil proc:nil];
    
    /* change folder icon of encrypted folder */
    [self setFolderIcon:self];    
    /* Register password with keyring */
 	
	/*** <!-- ENCFS END --> ***/
   
    
    
    
    
    
    
	
	/* If sharing is required */
    if (numberOfUsers == 2) {
		
		/***** MAILGUN TASK START ******/
		
		NSString *curlEmail = [NSString stringWithFormat:@"to=\"%@\"", yourFriendsEmailString];
		NSString *curlKey   = [NSString stringWithFormat:@"text=\%@\"", yourFriendsPassphraseString];
        
        [libFunctions execWithSocket:@"/usr/bin/curl" 
                           arguments:[NSArray arrayWithObjects: 
									  @"-s", @"-k", 
									  @"--user", @"api:key-67fgovcfrggd6y4l02ucpz-av4b22i26",
									  @"https://api.mailgun.net/v2/cloudclear.mailgun.org/messages",
									  @"-F", @"from='YouCrypt <postmaster@cloudclear.mailgun.org>'",
									  @"-F", curlEmail,
									  @"-F", @"subject='Your Temporary Passphrase'",
									  @"-F", curlKey,
									  nil]
                                 env:nil io:nil proc:nil];
		/***** <!-- MAILGUN END --> ******/
	}

    [yourPassword setStringValue:@""];
    [yourFriendsEmail setStringValue:@""];
    [self.window close];
}

-(void)setPassphraseTextField:(NSString*)string
{
    if (string != nil) {
        [yourPassword setStringValue:string];
    }
}


@end
