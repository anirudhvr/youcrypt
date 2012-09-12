//
//  RestoreController.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "RestoreController.h"
#import "libFunctions.h"
#import "core/YCFolder.h"
#import "AppDelegate.h"


@implementation RestoreController

@synthesize path;
@synthesize passwd;
@synthesize keychainHasPassphrase;
@synthesize dir;

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
    (void)sender;
    if (!self.keychainHasPassphrase)
        passwd = [passwordField stringValue];
    
    if (dir == nil) {
        DDLogError(@"Restoring of %@ failed; need non-nil dir\n", path);
        return;
    }
    
    if (!dir->restoreFolderInPlace()) {
        DDLogError(@"Restoring of %@ failed \n", path);
        NSAlert *alert = [NSAlert alertWithMessageText:@"Incorrect passphrase" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"The passphrase does not decrypt %@", [path stringByDeletingLastPathComponent]];
            [alert runModal];
    } else { // success
//        [self.window close];
        [theApp didRestore:path];
    }        
    return;
}

//-(IBAction)didMount:(id)sender {
//        
//    NSString *backPath = [path stringByDeletingLastPathComponent];
//    NSError *err;
//    NSFileManager *fm = [NSFileManager defaultManager];
//    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
//    
//    backPath = [backPath stringByAppendingPathComponent: [NSString stringWithFormat:@".%@",[[NSProcessInfo processInfo] globallyUniqueString]]];
//    
//    
//    DDLogInfo(@"didMount Backpath is %@\n", backPath);
//    
//    // Now to move the contents of tempFolder into backPath
//    // Unfortunately, a direct move won't work since blah blah blah
//
//    NSArray *files = [fm contentsOfDirectoryAtPath:tempFolder error:&err];
//    for (NSString *file in files) {
//        NSError *err;
//        if (([file isEqualToString:@".DS_Store"]) || ([file isEqualToString:YOUCRYPT_XMLCONFIG_FILENAME]))
//            continue;
//        if (![fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file] toPath:[backPath stringByAppendingPathComponent:file] error:&err]) {
//            //FIXME:  Restore error handler.
//            [[NSAlert alertWithError:err] runModal];
//        }
//    }    
//    
//    // Unmount the destination folder containing decrypted files    
//    if ([libFunctions execCommand:UMOUNT_CMD
//                        arguments:[NSArray arrayWithObject:tempFolder]
//                              env:nil]) {
//        DDLogError(@"ERROR: Umount failed.\nAborting\n");
//    }
//    [fm removeItemAtPath:tempFolder error:nil];
//    [fm removeItemAtPath:path error:nil];
//    [fm moveItemAtPath:backPath toPath:[path stringByDeletingPathExtension] error:nil];
//    [self.window close];
//    [theApp didRestore:path];
//
//}

- (IBAction)cancel:(id)sender {
    (void)sender;
    [self.window close];
    [theApp cancelRestore:path];
}


@end
