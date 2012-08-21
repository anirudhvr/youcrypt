//
//  Decrypt.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Decrypt.h"
#import "libFunctions.h"
#import "AppDelegate.h"
#import "PreferenceController.h"
#import "PassphraseManager.h"
#import "YoucryptDirectory.h"

@implementation Decrypt

@synthesize dir;
@synthesize passphraseFromKeychain;
@synthesize keychainHasPassphrase;

-(id)init
{
	self = [super init];
	if (![super initWithWindowNibName:@"Decrypt"])
        return nil;
    return self;

}

-(void)awakeFromNib
{
}

/**
 decrypt
 
 Captures the action of the decrypt button, when clicked 
 sender: window that sent this action 
**/

- (IBAction)decrypt:(id)sender
{	
	srcFolder = dir.path;
	destFolder = dir.mountedPath;
	NSString *yourPasswordString;
    if (keychainHasPassphrase)
        yourPasswordString = passphraseFromKeychain;
    else
        yourPasswordString = [yourPassword stringValue];
    
    NSString *volname = [[srcFolder stringByDeletingPathExtension] lastPathComponent];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"logo-512x512-alpha.icns", @"volicon", volname, @"volname", nil];
        
    int idletime = [[theApp.preferenceController getPreference:YC_IDLETIME] intValue];
    
    
    BOOL res =  [dir openEncryptedFolderAtMountPoint:destFolder
                                        withPassphrase:yourPasswordString
                                              idleTime:idletime
                                              fuseOpts:dict];
    if (res == YES) {
        [self close];
        [theApp didDecrypt:dir];
        return;
    } else {
        if (keychainHasPassphrase) {
            // The error wasn't the user's fault.
            // His keychain couldn't unlock it.
            DDLogInfo(@"Decrypt: Could not get pp from keyChain.");
            [self showWindow:nil];
            keychainHasPassphrase = NO;
            return;
        }
        else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Incorrect passphrase" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"The passphrase does not decrypt %@", [srcFolder stringByDeletingPathExtension]];
            [alert runModal];
            return;
        }
    }
}

- (IBAction)cancel:(id)sender {
    DDLogVerbose(@"Cancel decrypt : %@",dir.path);
    [self close];
    [theApp cancelDecrypt:dir];
}

@end
