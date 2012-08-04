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

@property (nonatomic, weak) IBOutlet NSSecureTextField *oldpassphrase;
@property (nonatomic, weak) IBOutlet NSSecureTextField *newpassphrase;
@property (nonatomic, weak) IBOutlet NSSecureTextField *verifynewpassphrase;
@property (nonatomic, weak) IBOutlet NSTextField *message;
@property (nonatomic, weak) NSArray *arr;

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end
