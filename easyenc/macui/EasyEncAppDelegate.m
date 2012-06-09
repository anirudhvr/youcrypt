//
//  SpeakLineAppDelegate.m
//  SpeakLine
//
//  Created by Anirudh Ramachandran on 6/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EasyEncAppDelegate.h"

@implementation SpeakLineAppDelegate

@synthesize window;

-(id)init
{
	[super init];
	NSLog(@"init Encrypt");
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	
	for (id arg in arguments) {
		if([arg isEqualToString:@"-d"]) {
			[window close];
			type = @"D"; // decrypt
			NSWindowController *myWindow = [[NSWindowController alloc]
											initWithWindowNibName:@"Decrypt"];
			[myWindow showWindow:self];
		}
		else if([arg isEqualToString:@"-e"]) {
			type = @"E"; // encrypt
		}
	}
	
}

void systemCallWithBinSh(NSString *binary, NSArray *args) {
    NSString *fileHeader = @"#!/bin/sh \n ";
    NSString *joinedArguments = [args componentsJoinedByString:@" "];
    NSString *fileContents = [NSString stringWithFormat:@"%@ %@ %@\n", 
                              fileHeader, binary, joinedArguments];
    NSLog(fileContents);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopDirectory=[paths objectAtIndex:0];
    NSString *filename = [desktopDirectory stringByAppendingString: @"/easyenc-tmp.sh"];
    [fileContents writeToFile:filename atomically:YES encoding: NSUTF8StringEncoding error: NULL];
    
    // At this point, we have already checked if script exists and has a shebang
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager isExecutableFileAtPath:filename]) {
        NSArray *chmodArguments = [NSArray arrayWithObjects:@"+x", filename, nil];
        NSTask *chmod = [NSTask launchedTaskWithLaunchPath:@"/bin/chmod" arguments:chmodArguments];
        [chmod waitUntilExit];
		[chmod release];
	}
    
    /* Finally run the goddamn file */
	NSArray *fileArgs = [NSArray arrayWithObjects: @" ", nil];
	
	NSTask *task = [NSTask launchedTaskWithLaunchPath:filename arguments:fileArgs];
	[task waitUntilExit];
	[task release];
    
	NSLog(@"This will not log !! # BUG ");
    //return NULL;
}

NSString* systemCall(NSString *binary, NSArray *arguments) {
	NSTask *task;	
	task = [[NSTask alloc] init];
	[task setLaunchPath: binary];
	
	[task setArguments: arguments];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	
	[task launch];
	
	NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
	
	[task waitUntilExit]; 
	[task release];
	
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
	
	NSLog (@"got\n%@", string); 
	
	return string;
}



- (IBAction)apply:(id)sender
{
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	
	NSMutableString *srcFolder = @"/Users/avr/new folder";// [arguments objectAtIndex:2];
	NSMutableString *destFolder = @"/Users/avr/new temp folder"; // [arguments objectAtIndex:3];
	
	NSString *srcFolderEscaped = [[srcFolder stringByReplacingOccurrencesOfString:@" "
													  withString:@"\\ "]
				 mutableCopy];
	NSString *destFolderEscaped = [[destFolder stringByReplacingOccurrencesOfString:@" "
													  withString:@"\\ "]
				 mutableCopy];
	
	NSLog(srcFolder);
	NSLog(destFolder);
		
	
	/*** PREPARATIONS
	 src = /Users/avr/d
	 mkdir -p $HOME/easyenc/src
	 mkdir -p /tmp/easyenc/src
	 cp -r src/* /tmp/easyenc/src
	 rm -rf src/*
	 ***/
	
	NSString *homeDirectory = NSHomeDirectory();
	NSLog(homeDirectory);
	/*
	NSFileManager *manager= [NSFileManager defaultManager]; 
	
	NSString *folderPath = [NSString stringWithFormat:@"\"%@/%@%@\"",homeDirectory, @"easyenc",srcFolderEscaped];
	
	if(![manager createDirectoryAtPath:folderPath attributes:nil])
			NSLog(@"Error: Create folder failed %@",folderPath);
	*/
	
	systemCall(@"/bin/mkdir",[NSArray arrayWithObjects: 
							@"-p", 
							[NSString stringWithFormat:@"\"%@/%@%@\"",homeDirectory, @"easyenc",srcFolder],
							  nil
							  ]);
	NSLog(@"mkdir %@",[NSString stringWithFormat:@"\"%@/%@%@\"",homeDirectory, @"easyenc",srcFolder]);
	
	/*
	folderPath = [NSString stringWithFormat:@"\"/tmp/easyenc%@\"",srcFolderEscaped];
	
		if(![manager createDirectoryAtPath:folderPath attributes:nil])
			NSLog(@"Error: Create folder failed %@",folderPath);
	*/
	 
	systemCall(@"/bin/mkdir", [NSArray arrayWithObjects:
							@"-p",
							[NSString stringWithFormat:@"\"/tmp/easyenc%@\"",srcFolder],
							   nil
							   ]);
	
	 NSLog(@"mkdir %@",[NSString stringWithFormat:@"\"/tmp/easyenc%@\"",srcFolder]);

	
	systemCallWithBinSh(@"/bin/mv", [NSArray arrayWithObjects:
							[NSString stringWithFormat:@"\"%@/\"*",srcFolder],
							[NSString stringWithFormat:@"\"/tmp/easyenc%@/\"",srcFolder],
							nil
							   ]);
	
	NSLog(@"This will not log either.. # BUG");
    /*
	systemCallWithBinSh(@"/bin/rm", [NSArray arrayWithObjects:
							@"-rf",
							[NSString stringWithFormat:@"%@/*",srcFolder],
							nil
							   ]);
    */
		
	/**** <!-- END PREP --> ***/
	
	
		NSString *yourEmailString = [yourEmail stringValue];
		NSString *yourPasswordString = [yourPassword stringValue];
		NSString *yourFriendsEmailString = [yourFriendsEmail stringValue];	
		NSString *combinedPasswordString, *numberOfUsers;	
		int yourFriendsPassphrase = arc4random() % 100000000;	
		NSString *yourFriendsPassphraseString = [NSString stringWithFormat:@"%d", yourFriendsPassphrase];
		if(![yourFriendsEmailString isEqualToString:@""]) {
			combinedPasswordString = [NSString stringWithFormat:@"%@%@%d", yourPasswordString, @",", yourFriendsPassphrase];
			numberOfUsers = @"2";
		//	[yourFriendsPassphrase retain];
		} else {
			combinedPasswordString = yourPasswordString;
			numberOfUsers = @"1";
		}
	
			
		//NSLog(yourEmailString);
		//NSLog(yourPasswordString);
	//	NSLog(yourFriendsEmailString);
	//	NSLog(combinedPasswordString);
		
		/****** ENCFS SYSTEM CALL 
		arguments = [NSArray arrayWithObjects: srcFolder, destFolder, @"--nu", numberOfUsers, @"--pw", combinedPasswordString, nil];
		
		NSTask *task;	
		task = [[NSTask alloc] init];
		[task setLaunchPath: @"/usr/local/bin/encfs"];
		
		
		[task setArguments: arguments];
		
		NSPipe *pipe;
		pipe = [NSPipe pipe];
		[task setStandardOutput: pipe];
		
		[task launch];
		
		NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
		
		[task waitUntilExit]; 
		[task release];
		
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
		
		NSLog (@"got\n%@", string); 
		
		[string release];
		 ****/
	
	systemCall(@"/usr/local/bin/encfs", [NSArray arrayWithObjects: 
										 srcFolderEscaped, 
										 destFolderEscaped, 
										 @"--nu", numberOfUsers, 
										 @"--pw", combinedPasswordString, 
										 nil
										 ]);
	
	/*** PREPARE ORIGINAL FOLDER
	 cp -r /tmp/easyenc/src/* $HOME/easyenc/src
	 rm -rf /tmp/easyenc/src
	 */
		
	systemCallWithBinSh(@"/bin/mv", [NSArray arrayWithObjects:
							[NSString stringWithFormat:@"\"/tmp/easyenc%@/\"*",srcFolder],
							[NSString stringWithFormat:@"\"%@\"/",destFolder],
							nil
							]);
	
    systemCall(@"/sbin/umount", [NSArray arrayWithObjects: 
                                  destFolder, 
                                 nil]);
	
		/*** <!-- ENCFS END --> ***/
		
		if([numberOfUsers isEqualToString:@"2"]) {
			
			/***** MAILGUN TASK START ******/
			
			NSTask *task;	
			task = [[NSTask alloc] init];
			[task setLaunchPath: @"/usr/bin/curl"];
			NSLog(@"GOING TO EMAIL: DETAILS ARE : ");
			NSLog(yourFriendsEmailString);
			NSLog(combinedPasswordString);
			NSLog(yourFriendsPassphraseString);
			
			NSString *curlEmail = [NSString stringWithFormat:@"to=\"%@\"", yourFriendsEmailString];
			NSLog(curlEmail);
			NSString *curlKey   = [NSString stringWithFormat:@"text=\%@\"", yourFriendsPassphraseString];
			
			arguments = [NSArray arrayWithObjects: 
						 @"-s", @"-k", 
						 @"--user", @"api:key-67fgovcfrggd6y4l02ucpz-av4b22i26",
						 @"https://api.mailgun.net/v2/cloudclear.mailgun.org/messages",
						 @"-F", @"from='YouCrypt <postmaster@cloudclear.mailgun.org>'",
						 @"-F", curlEmail,
						 @"-F", @"subject='Your Temporary Passphrase'",
						 @"-F", curlKey,
						 nil];
			
			[task setArguments: arguments];
			
			NSPipe *pipe;
			pipe = [NSPipe pipe];
			[task setStandardOutput: pipe];
			
			[task launch];
			
			NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
			
			[task waitUntilExit]; 
			[task release];
			
			NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
			
			NSLog (@"got\n%@", string); 
			
			[string release];
			
			/***** <!-- MAILGUN END --> ******/
		}

	
	[NSApp terminate: nil];
	
}



@end
