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

@synthesize sourceFolderPath;
@synthesize destFolderPath;

-(id)init
{
	self = [super init];
	if (![super initWithWindowNibName:@"Decrypt"])
        return nil;
    return self;

}

-(void)awakeFromNib
{
    NSLog(@"Decrypt awake from nib called");
    
    if (keychainHasPassphrase == NO) {
        passphraseFromKeychain = [libFunctions getPassphraseFromKeychain:@"Youcrypt"];
        if (passphraseFromKeychain == nil) {
            keychainHasPassphrase = NO;
        } else {
            keychainHasPassphrase = YES;
            [yourPassword setStringValue:passphraseFromKeychain];
        }
    }
    if (keychainHasPassphrase == YES) {
        [yourPassword setStringValue:passphraseFromKeychain];
    }
}

/**
 
 decrypt
 
 Captures the action of the decrypt button, when clicked
 
 sender: window that sent this action
 
**/

- (IBAction)decrypt:(id)sender
{	
	NSString *srcFolder = sourceFolderPath;
	NSString *destFolder = destFolderPath;
	
	NSString *yourPasswordString = [yourPassword stringValue];
    
    mkdirRecursive(destFolder);
		
    execWithSocket(@"/usr/local/bin/encfs", [NSArray arrayWithObjects:
                                         @"/usr/local/bin/encfs",
                                         srcFolder,
                                         destFolder, 
                                         @"--pw", yourPasswordString, 
                                         nil]);
    [[NSWorkspace sharedWorkspace] openFile:destFolder];
    DDLogVerbose(@"dfdsds");
	
}
@end
