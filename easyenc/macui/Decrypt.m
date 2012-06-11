//
//  Decrypt.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Decrypt.h"

@implementation Decrypt

-(id)init
{
	[super init];
	NSLog(@"init Decrypt");
	return self;
}

NSString* sysCall(NSString *binary, NSArray *arguments) {
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

- (IBAction)decrypt:(id)sender
{
	NSLog(@"Yayy ");
	BOOL decrypted = NO;
	
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	
	NSMutableString *srcFolder = [arguments objectAtIndex:2];
	NSMutableString *destFolder = [arguments objectAtIndex:3];
	/*	srcFolder = [[srcFolder stringByReplacingOccurrencesOfString:@" "
													  withString:@"\\ "]
				 mutableCopy];
	destFolder = [[destFolder stringByReplacingOccurrencesOfString:@" "
														withString:@"\\ "]
				  mutableCopy];
	*/
	NSLog(srcFolder);
	NSLog(destFolder);
	
	
		NSString *yourPasswordString = [yourPassword stringValue];
		
    sysCall(@"/usr/local/bin/encfs", [NSArray arrayWithObjects:
                                         srcFolder,
                                         destFolder, 
                                         @"--pw", yourPasswordString, 
                                         nil]);
    
    sysCall(@"/usr/bin/open", [NSArray arrayWithObject:destFolder]);
	
	[NSApp terminate: nil];
	
}
@end
