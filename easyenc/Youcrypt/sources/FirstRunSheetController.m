//
//  FirstRunSheetController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstRunSheetController.h"
#import "libFunctions.h"
#import "PreferenceController.h"

@interface FirstRunSheetController ()

@end

@implementation FirstRunSheetController

@synthesize name;
@synthesize email;
@synthesize password;
@synthesize confirmPassword;
@synthesize message;

- (id)init
{
    if (!(self = [super initWithWindowNibName:@"FirstRun"])) {
        return nil; // Bail!
    }
    return self;
}

- (void) setPreferenceController:(PreferenceController*)prefsController;
{
    preferenceController = prefsController;
}


- (void)windowDidLoad                                               
{
    [super windowDidLoad];
    
   // [name setStringValue:[preferenceController getPreference:YC_USERREALNAME]];
   // [email setStringValue:[preferenceController getPreference:YC_USEREMAIL]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)saveClicked:(id)sender {
    if([[password stringValue] isEqualToString:@""] || 
       [[password stringValue] isNotEqualTo:[confirmPassword stringValue]]) {
        
        [message setTextColor:[NSColor redColor]];
        [message setStringValue:@"Passwords do not match"];
        [confirmPassword setFocusRingType:NSFocusRingTypeExterior];
        [password setFocusRingType:NSFocusRingTypeExterior];
        
        return;
    } else {
        //[preferenceController setPreference:[email stringValue] value:YC_USEREMAIL];
        //[preferenceController setPreference:[name stringValue] value:YC_USERREALNAME];
        [[NSUserDefaults standardUserDefaults] setValue:[name stringValue] forKey:YC_USERREALNAME];
        [[NSUserDefaults standardUserDefaults] setValue:[email stringValue] forKey:YC_USEREMAIL];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [libFunctions registerWithKeychain:[password stringValue]:@"Youcrypt"];
        [self endSheetWithReturnCode:kSheetReturnedSave];
    }
}


// Mark: -
// Mark: Superclass overrides

- (void)sheetWillDisplay {
    [super sheetWillDisplay];
    
    
}

@end
