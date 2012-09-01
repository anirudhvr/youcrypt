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

@implementation Decrypt

@synthesize dir;
@synthesize passphraseFromKeychain;
@synthesize keychainHasPassphrase;
@synthesize mountPath;

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
    (void)sender;
    
    
	srcFolder = nsstrFromCpp(dir->rootPath());
	destFolder = self.mountPath;
	NSString *yourPasswordString;
    if (keychainHasPassphrase)
        yourPasswordString = passphraseFromKeychain;
    else
        yourPasswordString = [yourPassword stringValue];
    
    NSString *volname = [[srcFolder stringByDeletingPathExtension] lastPathComponent];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"logo-512x512-alpha.icns", @"volicon", volname, @"volname", nil];
        
    int idletime = [[theApp.preferenceController getPreference:YC_IDLETIME] intValue];
    BOOL res;
    std::vector<std::string> mount_opts, &fuse_opts = mount_opts;
    NSDictionary *fuseOpts = dict;
    for (NSString *key in [fuseOpts allKeys]) {
        NSString *opt;
        if ([key isEqualToString:@"volicon"]) {
            opt = [NSString stringWithFormat:@"-ovolicon=%@/Contents/Resources/%@", [libFunctions appBundlePath], [fuseOpts objectForKey:key]];
        } else {
            opt = [NSString stringWithFormat:@"-o%@=%@", key, [fuseOpts objectForKey:key]];
        }
        fuse_opts.push_back(std::string([opt cStringUsingEncoding:NSASCIIStringEncoding]));
    }
    fuse_opts.push_back(std::string("-ofsname=YoucryptFS"));

    if (idletime < 0) idletime = 0;
    
    if (dir->isUnlocked()) {
        dir->setMountLocation(cppString(destFolder));
        dir->setMountOpts(mount_opts, idletime);
        if (dir->mount()) {
            [self close];
            [theApp didDecrypt:dir];
        }
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
    (void)sender;
    [self close];
    [theApp cancelDecrypt:dir];
}

@end
