//
//  SheetController.m
//  JCSSheetController_Example
//
//  Created by Abizer Nasir on 19/02/2011.
//  Copyright 2011 Jungle Candy Software. All rights reserved.
//

#import "PassphraseSheetController.h"
#import "libFunctions.h"
#import "PassphraseManager.h"


@implementation PassphraseSheetController

@synthesize oldpassphrase;
@synthesize newpassphrase;
@synthesize verifynewpassphrase;
@synthesize message;
@synthesize arr;

- (id)initWithPassphraseManager:(PassphraseManager*)ppm {
    if (!(self = [super initWithWindowNibName:@"ChangePassphrase"])) {
        return nil; // Bail!
    }
    ppman = ppm;
    super.window = self.window;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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
    (void)sender;
    storedpassphrase = [ppman getPassphrase];
    if (storedpassphrase == nil) {
        
    } else {
        [oldpassphrase setEditable:YES];
        NSString *oldpp = [oldpassphrase stringValue];
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
        [ppman setPassPhrase:[newpassphrase stringValue]];
        long count = arr.count;
        for(int i=0;i<count;i++) {
            NSString *path = [arr objectAtIndex:i];
            [message setStringValue:[NSString stringWithFormat:@"Updating %ld%%",((i+1)*100)/count]];
//            BOOL ret = [libFunctions changeEncFSPasswd:path oldPasswd:[oldpassphrase stringValue] newPasswd:[newpassphrase stringValue]];
            BOOL ret = false;
            if (!ret)
                DDLogVerbose(@"Changing encfs password seems to have failed");
        }
        [self endSheetWithReturnCode:kSheetReturnedSave];
    }
}

- (void)cancelClicked:(id)sender {
    (void)sender;
    [self endSheetWithReturnCode:kSheetReturnedCancel];
}

// Mark: -
// Mark: Superclass overrides

- (void)sheetWillDisplay {
    [super sheetWillDisplay];
   
        
}

@end
