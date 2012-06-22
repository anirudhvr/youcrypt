//
//  Decrypt.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Decrypt.h"
#import "libFunctions.h"
#import "logging.h"

@implementation Decrypt

-(id)init
{
	self = [super init];
	if (![super initWithWindowNibName:@"Decrypt"])
        return nil;
    return self;

}

/**
 
 decrypt
 
 Captures the action of the decrypt button, when clicked
 
 sender: window that sent this action
 
**/

- (IBAction)decrypt:(id)sender
{	
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	
	NSString *srcFolder = [arguments objectAtIndex:2];
	NSString *destFolder = [arguments objectAtIndex:3];
	
	NSString *yourPasswordString = [yourPassword stringValue];
		
    systemCall(@"/usr/local/bin/encfs", [NSArray arrayWithObjects:
                                         srcFolder,
                                         destFolder, 
                                         @"--pw", yourPasswordString, 
                                         nil]);
    
    systemCall(@"/usr/bin/open", [NSArray arrayWithObject:destFolder]);
	
	[NSApp terminate: nil];
    DDLogVerbose(@"dfdsds");
	
}
@end
