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

@property (readwrite,copy) IBOutlet NSString *path;
@property (readwrite,copy) YoucryptDirectory *dir;
@property (readwrite,copy) NSString *passwd;
@property (readwrite,assign) BOOL keychainHasPassphrase;

- (IBAction) restore:(id)sender;


@end
