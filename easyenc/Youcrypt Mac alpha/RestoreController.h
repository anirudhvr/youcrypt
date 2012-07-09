//
//  RestoreController.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RestoreController : NSWindowController {
    IBOutlet NSSecureTextField *passwordField;
}

@property (readwrite,copy) IBOutlet NSString *path;
@property (readwrite,copy) NSString *passwd;

- (IBAction) restore:(id)sender;


@end
