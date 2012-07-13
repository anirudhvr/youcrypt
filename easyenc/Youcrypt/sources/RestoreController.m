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
    
    
    tempFolder = NSTemporaryDirectory();
    [libFunctions mkdirRecursive:tempFolder];
    tempFolder = [tempFolder stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    [libFunctions mkdirRecursive:tempFolder];
        
//    NSLog(@"Restoring %@: tmpDir = %@\n", path, tempFolder);
        
//    [libFunctions createEncFS:destFolder decryptedFolder:tempFolder numUsers:numberOfUsers combinedPassword:combinedPasswordString];
    
    NSNotificationCenter *nCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nCenter removeObserver:self];
    [nCenter addObserver:self selector:@selector(didMount:) name:NSWorkspaceDidMountNotification object:nil];
    
    
    if (![libFunctions mountEncFS:path decryptedFolder:tempFolder password:passwd volumeName:path]) {
        NSLog(@"Restoring failed at mountEncFs %@: tmpDir = %@\n", path, tempFolder);
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
            return;
        }

    }
    return;
}

-(IBAction)didMount:(id)sender {
        
    NSString *backPath = [path stringByDeletingLastPathComponent];
    NSLog(@"Backpath is %@\n", backPath);
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];

    
    // Now to move the contents of tempFolder into backPath
    // Unfortunately, a direct move won't work since both directories exist and
    // stupid macOS thinks it is overwriting the mount point we just created
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    NSArray *files = [fm contentsOfDirectoryAtPath:tempFolder error:&err];
//    if (err != nil) {        
//        [[NSAlert alertWithError:err] runModal];
//        // FIXME
//    }
    
    NSLog(@"files = %@\n", files);    
    for (NSString *file in files) {
        NSError *err;
        if (([file isEqualToString:@".DS_Store"]) || ([file isEqualToString:@".youcryptfs.xml"]))
            continue;
        if (![fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file] toPath:[backPath stringByAppendingPathComponent:file] error:&err]) {
            //            [[NSAlert alertWithError:err] runModal];
        }
        NSLog(@"Moving %@ to %@", 
              [tempFolder stringByAppendingPathComponent:file],
              [backPath stringByAppendingPathComponent:file]
              );
    }    
    
    // Unmount the destination folder containing decrypted files    
    if ([libFunctions execCommand:@"/sbin/umount" arguments:[NSArray arrayWithObject:tempFolder]
                              env:nil]) {
        NSLog(@"Umount failed.\nAborting\n");
    }
    [fm removeItemAtPath:tempFolder error:nil];
    [fm removeItemAtPath:path error:nil];
    [theApp didRestore:path];
    [self.window close];

}

- (IBAction)cancel:(id)sender {
    [theApp cancelRestore:path];
    [self.window close];
}


@end
