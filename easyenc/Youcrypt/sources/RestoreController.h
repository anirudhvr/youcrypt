//
//  RestoreController.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class YoucryptDirectory;

@interface RestoreController : NSWindowController {
    IBOutlet NSSecureTextField *passwordField;
    NSString *tempFolder;
}

@property (atomic,strong) IBOutlet NSString *path;
@property (atomic,strong) YoucryptDirectory *dir;
@property (atomic,strong) NSString *passwd;
@property (readwrite,assign) BOOL keychainHasPassphrase;

- (IBAction) restore:(id)sender;


@end
