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

@implementation Encrypt


@synthesize sourceFolderPath;
@synthesize destFolderPath;
@synthesize lastEncryptionStatus;
@synthesize encryptionInProcess;

-(id)init
{
	self = [super init];
	if (![super initWithWindowNibName:@"Encrypt"])
        return nil;
    return self;
}



/**
 
 mkdirRecursive
 
 Obj-c equivalent of mkdir -p
 
 path : path of Directory we want to create
 
**/

/**
 
 apply
 
 Captures the action of the Apply button in Encrypt window.
 
 sender: window who sent the action
 
**/

- (IBAction)encrypt:(id)sender
{
//	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	
//	NSMutableString *srcFolder = [arguments objectAtIndex:2];
    	NSMutableString *srcFolder = sourceFolderPath;
//	NSMutableString *destFolder = [arguments objectAtIndex:3];
    	NSMutableString *destFolder = destFolderPath;
	
	/*** 
	 PREPARATIONS
	 A mkdir -p $HOME/easyenc/src 
	 B mkdir -p /tmp/easyenc/src
	 C cp -r src/* /tmp/easyenc/src
	 D rm -rf src/*
	 ***/
	
	NSString *tempFolder = [@"/tmp/easyenc/" stringByAppendingPathComponent:srcFolder];
	
	NSLog(@"Create destination %@ if it doesn't already exist",destFolder);
    NSLog(@"mkdir tempfolder [%@]",tempFolder);
	
	/* A */
	mkdirRecursive(destFolder);
	
	/* B */
	mkdirRecursive(tempFolder);
	
	
	/* C+D */
	mvRecursive(srcFolder, tempFolder);
    
    srcFolder = [srcFolder stringByAppendingPathComponent:@"/encrypted.yc"];
    mkdirRecursive(srcFolder);
    
	/**** <!-- END PREP --> ***/
	
	
	/*** ENCFS START ***/
	
	NSString *yourEmailString = [yourEmail stringValue];
	NSString *yourPasswordString = [yourPassword stringValue];
	NSString *yourFriendsEmailString = [yourFriendsEmail stringValue];	
	NSString *combinedPasswordString, *numberOfUsers;	
	int yourFriendsPassphrase;	
	NSString *yourFriendsPassphraseString;
	
	// check if user wants to share with a friend
	if(![yourFriendsEmailString isEqualToString:@""]) {
		yourFriendsPassphrase = arc4random() % 100000000;
		yourFriendsPassphraseString = [NSString stringWithFormat:@"%d", yourFriendsPassphrase];
		combinedPasswordString = [NSString stringWithFormat:@"%@%@%d", yourPasswordString, @",", yourFriendsPassphrase];
		numberOfUsers = @"2";
	} 
	else {
		// nope, no sharing
		combinedPasswordString = yourPasswordString;
		numberOfUsers = @"1";
	}
	
	/* Actual encfs call */
	systemCall(@"/usr/local/bin/encfs", [NSArray arrayWithObjects: 
										 srcFolder, 
										 destFolder, 
										 @"--nu", numberOfUsers, 
										 @"--pw", combinedPasswordString, 
										 nil
										 ]);
	
    
	/*** 
	 PREPARE ORIGINAL FOLDER
	 cp -r /tmp/easyenc/src/* $HOME/easyenc/src
	 rm -rf /tmp/easyenc/src
	***/
	
	
	mvRecursive(tempFolder, destFolder);
	
    // Unmount the destination folder containing decrypted files
	systemCall(@"/sbin/umount", [NSArray arrayWithObjects: 
								 destFolder, 
                                 nil]);
	
	/*** <!-- ENCFS END --> ***/
	
	/* If sharing is required */
	if([numberOfUsers isEqualToString:@"2"]) {
		
		/***** MAILGUN TASK START ******/
		
		NSString *curlEmail = [NSString stringWithFormat:@"to=\"%@\"", yourFriendsEmailString];
		NSString *curlKey   = [NSString stringWithFormat:@"text=\%@\"", yourFriendsPassphraseString];
		
		systemCall(@"/usr/bin/curl", [NSArray arrayWithObjects: 
									  @"-s", @"-k", 
									  @"--user", @"api:key-67fgovcfrggd6y4l02ucpz-av4b22i26",
									  @"https://api.mailgun.net/v2/cloudclear.mailgun.org/messages",
									  @"-F", @"from='YouCrypt <postmaster@cloudclear.mailgun.org>'",
									  @"-F", curlEmail,
									  @"-F", @"subject='Your Temporary Passphrase'",
									  @"-F", curlKey,
									  nil]);
		
		/***** <!-- MAILGUN END --> ******/
	}
	
	[NSApp terminate: nil];
	
}

@end
