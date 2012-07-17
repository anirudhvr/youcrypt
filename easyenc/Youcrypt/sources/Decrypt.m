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
}

/**
 decrypt
 
 Captures the action of the decrypt button, when clicked 
 sender: window that sent this action 
**/

- (IBAction)decrypt:(id)sender
{	
	srcFolder = sourceFolderPath;
	destFolder = destFolderPath;	
	NSString *yourPasswordString;
    if (keychainHasPassphrase)
        yourPasswordString = passphraseFromKeychain;
    else
        yourPasswordString = [yourPassword stringValue];
    
    [libFunctions mkdirRecursive:destFolder]; 
    //FIXME
    NSString *volname = [[srcFolder stringByDeletingPathExtension] lastPathComponent];    
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
    DDLogVerbose(@"Cancel decrypt : %@",sourceFolderPath);
    [theApp cancelDecrypt:sourceFolderPath];
    [self close];
}

- (IBAction)didMount:(id)sender {
//    NSString *destFolder = destFolderPath;	
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    
    if (keychainHasPassphrase == NO) {
        // Check if there's a different passphrase in the keychain.
        NSString *keyPP = [libFunctions getPassphraseFromKeychain:@"Youcrypt"];
        if ((keyPP != nil) && ![keyPP isEqualToString:@""]) {
            // Seems like a non-empty passphrase...
            // Suggest that the user change the passphrase of the current folder.        
        
            int retCode = [[NSAlert alertWithMessageText:@"Change passphrase?" 
                                           defaultButton:@"Yes, change this" 
                                         alternateButton:@"No, leave this as is" 
                                             otherButton:nil 
                               informativeTextWithFormat:@"Passphrase for %@ is different from your youcrypt passphrase.  Do you want to change the passphrase of the folder to your keychain passphrase?", sourceFolderPath] runModal];
            if (retCode == NSAlertDefaultReturn) {
                //FIXME:  Show an error if this failed ?
                BOOL ret = [libFunctions changeEncFSPasswd:sourceFolderPath 
                                                 oldPasswd:[yourPassword stringValue]
                                                 newPasswd:keyPP];
                DDLogInfo(@"didMount: changeEncfsPwd returned : %d",ret);
            }
        }
    }   
    
    
//    [[NSWorkspace sharedWorkspace] openFile:destFolder];	
    [theApp didDecrypt:sourceFolderPath];
    [self close];
}
@end
