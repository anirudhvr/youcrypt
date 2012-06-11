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

void createDirectoryRecursivelyAtPath(NSString *path)
{
	//check if the dir just above exists...
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir;
	NSString *directoryAbove = [path stringByDeletingLastPathComponent];
	NSLog(@"Checking %@",directoryAbove);
	if (![fileManager fileExistsAtPath:directoryAbove isDirectory:&isDir])
	{
		// call ourself with the directory above...
		NSLog(@"Going to create %@",directoryAbove);
		createDirectoryRecursivelyAtPath(directoryAbove);
	}
	// Now we enforced that the dir exist
	// Fine, create the dir...
	[fileManager createDirectoryAtPath:path attributes:nil];
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
void mvRecursive(NSString *pathFrom, NSString *pathTo) {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *files = [manager contentsOfDirectoryAtPath:pathFrom error:nil];
	
	for (NSString *file in files) {
		NSString *fileFrom = [pathFrom stringByAppendingPathComponent:file];
		BOOL isDir;
		
		NSString *fileTo = [pathTo stringByAppendingPathComponent:file];
		
		NSError  *error  = nil;
		
		NSLog(@"about to copy %@",fileFrom);
		
		[manager copyItemAtPath:fileFrom toPath:fileTo error:&error];
		[manager removeItemAtPath:fileFrom error:&error];
		if (error) {
			NSLog(@"%@",[error localizedDescription]);
		}
	}
}

void mkdir(NSString *path) {

	NSFileManager *manager = [NSFileManager defaultManager];
	[manager createDirectoryAtPath:path attributes:nil];
	
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
	
	NSMutableString *srcFolder =  [arguments objectAtIndex:2];
	NSMutableString *destFolder = [arguments objectAtIndex:3];
	
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
	
	
	NSLog(@"Create %@ if it doesn't already exist",destFolder);
	
	mkdir(destFolder);
	
	createDirectoryRecursivelyAtPath([NSString stringWithFormat:@"%@/easyencd%@",homeDirectory,srcFolder]);
	
	NSLog(@"mkdir %@",[NSString stringWithFormat:@"\"%@/easyencd%@\"",homeDirectory,srcFolder]);
	
	
	createDirectoryRecursivelyAtPath([NSString stringWithFormat:@"/tmp/easyencd%@",srcFolder]);
	
		
	NSLog(@"mkdir %@",[NSString stringWithFormat:@"\"/tmp/easyencd%@\"",srcFolder]);
	
	
	mvRecursive(srcFolder, [NSString stringWithFormat:@"/tmp/easyencd%@/",srcFolder]);
	
		
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
	 */
	
	
	mvRecursive([NSString stringWithFormat:@"/tmp/easyencd%@/",srcFolder],
				destFolder);
	
    /*
	systemCall(@"/sbin/umount", [NSArray arrayWithObjects: 
								 destFolder, 
                                 nil]);
	*/
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
