//
//  SheetController.m
//  JCSSheetController_Example
//
//  Created by Abizer Nasir on 19/02/2011.
//  Copyright 2011 Jungle Candy Software. All rights reserved.
//

#import "PassphraseSheetController.h"
#import "libFunctions.h"


@implementation PassphraseSheetController

@synthesize oldpassphrase;
@synthesize newpassphrase;
@synthesize verifynewpassphrase;
@synthesize message;

- (id)init {
    if (!(self = [super initWithWindowNibName:@"ChangePassphrase"])) {
        return nil; // Bail!
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    
    NSLog(@"Windowdidload called");
}

-(void) sheetDidDisplay
{
    [message setStringValue:@""];
    [oldpassphrase setStringValue:@""];
    [newpassphrase setStringValue:@""];
    [verifynewpassphrase setStringValue:@""];
    
}
// Mark: -
// Mark: Action methods

- (void)saveClicked:(id)sender {
    
    storedpassphrase = [libFunctions getPassphraseFromKeychain:@"Youcrypt"];
    if (storedpassphrase == nil) {

    } else {
        [oldpassphrase setEditable:YES];
        NSLog(@"Got stored passphrase: %@", storedpassphrase);
        NSString *oldpp = [oldpassphrase stringValue];
        NSLog(@"value of oldpassphrase [%@],  storedpassphrase: [%@], isEqual: %d", oldpp, storedpassphrase,[oldpp isEqualToString:storedpassphrase]);
        if (![oldpp isEqualToString:storedpassphrase]) {
            [message setTextColor:[NSColor redColor]];
            [message setStringValue:@"Old password does not match password stored in keychain"];
            return;
        }
    }

    if (![[newpassphrase stringValue] isEqualToString:[verifynewpassphrase stringValue]]) {
        [message setTextColor:[NSColor redColor]];
        [message setStringValue:@"New passwords do not match"];
        return;
    } else {
        NSLog(@"Registering new passphrase %@ with keychain", [newpassphrase stringValue]);
        [libFunctions registerWithKeychain:[newpassphrase stringValue]:@"Youcrypt"];
        [self endSheetWithReturnCode:kSheetReturnedSave];
    }
}

- (void)cancelClicked:(id)sender {
    [self endSheetWithReturnCode:kSheetReturnedCancel];
}

// Mark: -
// Mark: Superclass overrides

- (void)sheetWillDisplay {
    [super sheetWillDisplay];
    NSLog(@"Change passphrase sheet will display");
   
        
}

@end
