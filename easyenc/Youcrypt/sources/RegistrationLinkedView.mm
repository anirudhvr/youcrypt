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
#import "PassphraseManager.h"
#import "core/Settings.h"
#import "AppDelegate.h"

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
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(updateStatusMessage:) name:@"RegistrationLinkedViewUpdateStatus" object:nil];
}

- (void)continueClicked:(id)sender {
//    NSLog(@" username %@",[preferenceController getPreference:YC_USERREALNAME]);
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
        
//        NSError *err;
//        if (![theApp.passphraseManager setPassphrase:[password stringValue] error:&err]) {
//            [msg setStringValue:[@"Insecure password: " stringByAppendingString:[err localizedDescription]]];
//            [password setFocusRingType:NSFocusRingTypeExterior];
//            [confirmPassword setFocusRingType:NSFocusRingTypeExterior];
//            return;
//        }
//              
        //[preferenceController setPreference:[email stringValue] value:YC_USEREMAIL];
        //[preferenceController setPreference:[name stringValue] value:YC_USERREALNAME];
        [[NSUserDefaults standardUserDefaults] setValue:[name stringValue] forKey:YC_USERREALNAME];
        [[NSUserDefaults standardUserDefaults] setValue:[email stringValue] forKey:YC_USEREMAIL];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // [libFunctions registerWithKeychain:[password stringValue]:@"Youcrypt"];
        
        if (![theApp setupCM:[password stringValue]
            createIfNotFound:YES createAccount:YES pushKeys:YES]) {
            [msg setStringValue:@"Unknown error creating credentials."];
            return;
        }
    }
    
    [super goToNextView];
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
