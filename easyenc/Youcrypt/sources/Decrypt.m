//
//  Decrypt.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Decrypt.h"
#import "libFunctions.h"
#import "Contrib/Lumberjack/logging.h"
#import "AppDelegate.h"
#import "PreferenceController.h"

@implementation Decrypt

@synthesize sourceFolderPath;
@synthesize destFolderPath;
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
    NSLog(@"Decrypt awake from nib called");    
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
	NSString *yourPasswordString;
    if (keychainHasPassphrase)
        yourPasswordString = passphraseFromKeychain;
    else
        yourPasswordString = [yourPassword stringValue];
    
    [libFunctions mkdirRecursive:destFolder]; 
    
    NSString *volname = [[srcFolder stringByDeletingLastPathComponent] lastPathComponent];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"logo-512x512-alpha.icns", @"volicon", volname, @"volname", nil];
        
    /*
     Dead Store:
    BOOL encfnames = NO;
    if ([[theApp.preferenceController getPreference:YC_ENCRYPTFILENAMES] intValue] != 0)
        encfnames = YES;
    */
    int idletime = [[theApp.preferenceController getPreference:YC_IDLETIME] intValue];
     
    
    NSNotificationCenter *nCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nCenter removeObserver:self];
    [nCenter addObserver:self selector:@selector(didMount:) name:NSWorkspaceDidMountNotification object:nil];
    
    BOOL res = [libFunctions mountEncFS:srcFolder decryptedFolder:destFolder password:yourPasswordString fuseOptions:dict idleTime:idletime ];

    if (res == YES) {
        return;
    } else {
        if (keychainHasPassphrase) {
            // The error wasn't the user's fault.
            // His keychain couldn't unlock it.
            [self showWindow:nil];
            keychainHasPassphrase = NO;
            return;
        }
        else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Incorrect passphrase" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"The passphrase does not decrypt %@", [srcFolder stringByDeletingLastPathComponent]];
            [alert runModal];
            return;
        }
    }
}

- (IBAction)cancel:(id)sender {
    [theApp cancelDecrypt:sourceFolderPath];
    [self close];
}

- (IBAction)didMount:(id)sender {
    NSString *destFolder = destFolderPath;	
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    
    [[NSWorkspace sharedWorkspace] openFile:destFolder];	
    [theApp didDecrypt:sourceFolderPath];
    [self close];
}
@end
