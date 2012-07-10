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
@synthesize arr;

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
        [message setStringValue:@"Please Wait. It may take a while."];
        NSLog(@"Registering new passphrase %@ with keychain", [newpassphrase stringValue]);
        [libFunctions registerWithKeychain:[newpassphrase stringValue]:@"Youcrypt"];
        int count = arr.count;
        for(int i=0;i<count;i++) {
            NSLog(@"Updating dir %d",i+1);
            NSString *path = [[arr objectAtIndex:i] path];
            [message setStringValue:[NSString stringWithFormat:@"Updating %d%%",((i+1)/count)*100]];
            BOOL ret = [libFunctions changeEncFSPasswd:path oldPasswd:[oldpassphrase stringValue] newPasswd:[newpassphrase stringValue]];
            NSLog(@"Return value : %d",ret);
        }
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
