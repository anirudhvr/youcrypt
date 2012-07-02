//
//  SheetController.h
//  JCSSheetController_Example
//
//  Created by Abizer Nasir on 19/02/2011.
//  Copyright 2011 Jungle Candy Software. All rights reserved.
//

enum {
    kSheetReturnedSave = 1,
    kSheetReturnedCancel = 2
};

#import <Cocoa/Cocoa.h>
#import "JCSSheetController.h"


@interface PassphraseSheetController : JCSSheetController {
    NSString *storedpassphrase;
}

@property (nonatomic, weak) IBOutlet NSSecureTextField *oldpassphrase;
@property (nonatomic, weak) IBOutlet NSSecureTextField *newpassphrase;
@property (nonatomic, weak) IBOutlet NSSecureTextField *verifynewpassphrase;
@property (nonatomic, weak) IBOutlet NSTextField *message;

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end
