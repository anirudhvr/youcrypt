//
//  RestoreController.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "core/YCFolder.h"
using namespace youcrypt;

@interface RestoreController : NSWindowController {
    IBOutlet NSSecureTextField *passwordField;
    NSString *tempFolder;
    Folder dir;
}

@property (atomic,strong) IBOutlet NSString *path;
@property (atomic,strong) NSString *passwd;
@property (readwrite,assign) BOOL keychainHasPassphrase;
@property (assign) Folder dir;

- (IBAction) restore:(id)sender;


@end
