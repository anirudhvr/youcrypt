//
//  RegistrationLinkedView.m
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 7/12/15.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "RegistrationLinkedView.h"
#import "libFunctions.h"
#import "PreferenceController.h"
#import "AppDelegate.h"
#import "ConfigDirectory.h"
#import "PassphraseManager.h"

@implementation RegistrationLinkedView

@synthesize name;
@synthesize email;
@synthesize password;
@synthesize confirmPassword;
@synthesize msg;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) setPreferenceController:(PreferenceController*)prefsController;
{
    preferenceController = prefsController;
}


- (void)awakeFromNib                                               
{
    [super awakeFromNib];
    preferenceController = [theApp preferenceController];
    
    //[name setStringValue:[preferenceController getPreference:YC_USERREALNAME]];
    //[email setStringValue:[preferenceController getPreference:YC_USEREMAIL]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)continueClicked:(id)sender {
    NSLog(@" username %@",[preferenceController getPreference:YC_USERREALNAME]);
    if([[password stringValue] isEqualToString:@""] || 
       [[password stringValue] isNotEqualTo:[confirmPassword stringValue]]) {
        
        [msg setTextColor:[NSColor redColor]];
        [msg setStringValue:@"Passwords do not match"];
        [confirmPassword setFocusRingType:NSFocusRingTypeExterior];
        [password setFocusRingType:NSFocusRingTypeExterior];
        return;
    } else if (![libFunctions validateEmail:[email stringValue]]) {
        [msg setTextColor:[NSColor redColor]];
        [msg setStringValue:@"Invalid email"];
        [email setFocusRingType:NSFocusRingTypeExterior];
        return;
    } else {
        //[preferenceController setPreference:[email stringValue] value:YC_USEREMAIL];
        //[preferenceController setPreference:[name stringValue] value:YC_USERREALNAME];
        [[NSUserDefaults standardUserDefaults] setValue:[name stringValue] forKey:YC_USERREALNAME];
        [[NSUserDefaults standardUserDefaults] setValue:[email stringValue] forKey:YC_USEREMAIL];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [theApp.passphraseManager setPassphrase:[password stringValue]];
        // [libFunctions registerWithKeychain:[password stringValue]:@"Youcrypt"];
        [theApp.configDir firstRunSuccessful];

    }
    
    [super goToNextView];
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
