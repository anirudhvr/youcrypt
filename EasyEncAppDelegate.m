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
	
	NSString *srcFolder = [arguments objectAtIndex:2];
	NSString *destFolder = [arguments objectAtIndex:3];
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
	
	systemCall(@"/bin/ls", [NSArray arrayWithObjects:
							@"-al",
							@"/tmp/*"]
			   );
	
	systemCall(@"/bin/mkdir",[NSArray arrayWithObjects: 
							@"-p", 
							[NSString stringWithFormat:@"%@/%@%@",homeDirectory, @"easyenc",srcFolder],
							  nil
							  ]);
	
	systemCall(@"/bin/mkdir", [NSArray arrayWithObjects:
							@"-p",
							[NSString stringWithFormat:@"/tmp/easyenc%@",srcFolder],
							   nil
							   ]);
	
	systemCall(@"/bin/cp", [NSArray arrayWithObjects:
							@"-r",
							[NSString stringWithFormat:@"%@/*",srcFolder],
							[NSString stringWithFormat:@"/tmp/easyenc%@",srcFolder],
							nil
							   ]);
	
	systemCall(@"/bin/rm", [NSArray arrayWithObjects:
							@"-rf",
							[NSString stringWithFormat:@"%@/*",srcFolder],
							nil
							   ]);
		
	
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
			[yourFriendsPassphrase retain];
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
										 srcFolder, 
										 destFolder, 
										 @"--nu", numberOfUsers, 
										 @"--pw", combinedPasswordString, 
										 nil
										 ]);
	
	/*** PREPARE ORIGINAL FOLDER
	 cp -r /tmp/easyenc/src/* $HOME/easyenc/src
	 rm -rf /tmp/easyenc/src
	 ***/
		
	systemCall(@"/bin/cp", [NSArray arrayWithObjects:
							@"-r",
							[NSString stringWithFormat:@"/tmp/easyenc%@/*",srcFolder],
							[NSString stringWithFormat:@"%@/easyenc%@",homeDirectory, srcFolder],
							nil
							]);
	
	
	systemCall(@"/bin/rm", [NSArray arrayWithObjects:
							@"-rf",
							[NSString stringWithFormat:@"/tmp/easyenc%@/",srcFolder],
							nil
							]);
	
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
			
			NSString *curlEmail = [NSString stringWithFormat:@"to='%@'", yourFriendsEmailString];
			NSLog(curlEmail);
			NSString *curlKey   = [NSString stringWithFormat:@"text='%@'", yourFriendsPassphraseString];
			
			arguments = [NSArray arrayWithObjects: 
						 @"-s", @"-k", 
						 @"--user", @"api:key-51pzkithdv41-pu7y70xelro2-2a6s76",
						 @"https://api.mailgun.net/v2/youcrypt.mailgun.org/messages",
						 @"-F", @"from='Postmaster <postmaster@youcrypt.mailgun.org>'",
						 @"-F", curlEmail,
						 @"-F", @"subject='Your Key'",
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
			
			//NSLog (@"got\n%@", string); 
			
			[string release];
			
			/***** <!-- MAILGUN END --> ******/
		}

	
	[NSApp terminate: nil];
	
}



@end
