//
//  RestoreController.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "RestoreController.h"
#import "libFunctions.h"
#import "AppDelegate.h"


@implementation RestoreController

@synthesize path;
@synthesize passwd;
@synthesize keychainHasPassphrase;

- (id)init //WithWindow:(NSWindow *)window
{
    self = [super initWithWindowNibName:@"Restore"];
    if (self) {
        // Initialization code here.
    }    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction) restore:(id)sender
{
    if (!self.keychainHasPassphrase)
        passwd = [passwordField stringValue];
    
    
    NSString *tempFolder = NSTemporaryDirectory();
    [libFunctions mkdirRecursive:tempFolder];
    tempFolder = [tempFolder stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    [libFunctions mkdirRecursive:tempFolder];
        
    NSLog(@"Restoring %@: tmpDir = %@\n", path, tempFolder);
        
//    [libFunctions createEncFS:destFolder decryptedFolder:tempFolder numUsers:numberOfUsers combinedPassword:combinedPasswordString];
    if (![libFunctions mountEncFS:path decryptedFolder:tempFolder password:passwd volumeName:path]) {
        if (self.keychainHasPassphrase) {
            // The error wasn't the user's fault.
            // His keychain couldn't unlock it.
            [self showWindow:nil];
            self.keychainHasPassphrase = NO;
            return;
        }
        else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Incorrect passphrase" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"The passphrase does not decrypt %@", [path stringByDeletingLastPathComponent]];
            [alert runModal];
        }

    }
    
    NSString *backPath = [path stringByDeletingLastPathComponent];
    
    // Now to move the contents of tempFolder into backPath
    // Unfortunately, a direct move won't work since both directories exist and
    // stupid macOS thinks it is overwriting the mount point we just created
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:tempFolder error:nil];
    for (NSString *file in files) {
        [fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file] toPath:[backPath stringByAppendingPathComponent:file] error:nil];
        NSLog(@"Moving %@ to %@", 
              [tempFolder stringByAppendingPathComponent:file],
              [backPath stringByAppendingPathComponent:file]
              );
    }    
    
    // Unmount the destination folder containing decrypted files
    [libFunctions execCommand:@"/sbin/umount" arguments:[NSArray arrayWithObject:tempFolder]
                          env:nil];
    [fm removeItemAtPath:tempFolder error:nil];
    [fm removeItemAtPath:path error:nil];
    [theApp didRestore:path];
    [self.window close];
}


@end
