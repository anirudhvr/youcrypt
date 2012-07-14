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

- (void) setPreferenceController:(PreferenceController*)prefsController;
{
    preferenceController = prefsController;
}


-(void) sheetDidDisplay
{
    if(!(([preferenceController getPreference:YC_GMAILUSERNAME] == nil) || ([preferenceController getPreference:YC_GMAILUSERNAME] == @""))) {
        [username setStringValue:[preferenceController getPreference:YC_GMAILUSERNAME]];
        [password setStringValue:[libFunctions getPassphraseFromKeychain:@"ycgmail"]];
    }
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSLog(@"GMail window loaded");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

// Mark: -
// Mark: Action methods

- (IBAction)saveClicked:(id)sender {
        //NSLog(@"Registering new passphrase %@ with keychain", [password stringValue]);
        [libFunctions registerWithKeychain:[password stringValue]:@"ycgmail"];
        [preferenceController setPreference:YC_GMAILUSERNAME value:[username stringValue]];
        NSLog(@"GMAIL USERNAME: %@ %@",YC_GMAILUSERNAME,[username stringValue]);
        [username setStringValue:@""];
        [password setStringValue:@""];
        [username becomeFirstResponder];
        [self endSheetWithReturnCode:kSheetReturnedSave];
}

- (void)cancelClicked:(id)sender {
    [self endSheetWithReturnCode:kSheetReturnedCancel];
}

// Mark: -
// Mark: Superclass overrides

- (void)sheetWillDisplay {
    [super sheetWillDisplay];
    NSLog(@"Gmail sheet will display");
}


@end
