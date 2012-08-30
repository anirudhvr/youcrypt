//
//  GmailSheetController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GmailSheetController.h"
#import "libFunctions.h"
#import "PreferenceController.h"

@interface GmailSheetController ()

@end

@implementation GmailSheetController

@synthesize username;
@synthesize password;

- (id)init
{
    if (!(self = [super initWithWindowNibName:@"Gmail"])) {
        return nil; // Bail!
    }
    return self;
}

- (void) setPreferenceController:(PreferenceController*)prefsController
{
    preferenceController = prefsController;
}


-(void) sheetDidDisplay
{
    if(!(([preferenceController getPreference:YC_GMAILUSERNAME] == nil) || ([preferenceController getPreference:YC_GMAILUSERNAME] == @""))) {
        [username setStringValue:[preferenceController getPreference:YC_GMAILUSERNAME]];
        //[password setStringValue:[libFunctions getPassphraseFromKeychain:@"ycgmail"]];
    }
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

// Mark: -
// Mark: Action methods

- (IBAction)saveClicked:(id)sender {
    (void)sender;
   //     [libFunctions registerWithKeychain:[password stringValue]:@"ycgmail"];
        [preferenceController setPreference:YC_GMAILUSERNAME value:[username stringValue]];
        [username setStringValue:@""];
        [password setStringValue:@""];
        [username becomeFirstResponder];
        [self endSheetWithReturnCode:kSheetReturnedSave];
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
