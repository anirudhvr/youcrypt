//
//  SheetController.h
//  JCSSheetController_Example
//
//  Created by Abizer Nasir on 19/02/2011.
//  Copyright 2011 Jungle Candy Software. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "Contrib/JCSSheet/JCSSheetController.h"
@class PassphraseManager;


@interface PassphraseSheetController : JCSSheetController {
    NSString *storedpassphrase;
    PassphraseManager *ppman;
}

@property (atomic, strong) IBOutlet NSSecureTextField *oldpassphrase;
@property (atomic, strong) IBOutlet NSSecureTextField *newpassphrase;
@property (atomic, strong) IBOutlet NSSecureTextField *verifynewpassphrase;
@property (atomic, strong) IBOutlet NSTextField *message;
@property (atomic, strong) NSArray *arr;

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end
