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
    passwd = [passwordField stringValue];
    
    
    NSString *tempFolder = NSTemporaryDirectory();
    [libFunctions mkdirRecursive:tempFolder];
    tempFolder = [tempFolder stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    [libFunctions mkdirRecursive:tempFolder];
        
    
    [[NSAlert alertWithMessageText:@"HI" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"About to take care of %@", path] runModal];
    
//    [libFunctions createEncFS:destFolder decryptedFolder:tempFolder numUsers:numberOfUsers combinedPassword:combinedPasswordString];
    [libFunctions mountEncFS:path decryptedFolder:tempFolder password:passwd volumeName:path];
    
    NSString *backPath = [path stringByDeletingLastPathComponent];
    
    
    // Now to move the contents of tempFolder into backPath
    // Unfortunately, a direct move won't work since both directories exist and
    // stupid macOS thinks it is overwriting the mount point we just created
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:tempFolder error:nil];
    for (NSString *file in files) {
        [fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file] toPath:[backPath stringByAppendingPathComponent:file] error:nil];
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
