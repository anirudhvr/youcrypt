//
//  DBLinkedView.h
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "LinkedView.h"
#import "Contrib/JCSSheet/JCSSheetController.h"

@class PreferenceController;

@interface RegistrationLinkedView : LinkedView
{
    PreferenceController *preferenceController;
}

@property (atomic, strong) IBOutlet NSTextField *name;
@property (atomic, strong) IBOutlet NSTextField *email;
@property (atomic, strong) IBOutlet NSTextField *msg;
@property (atomic, strong) IBOutlet NSSecureTextField *password;
@property (atomic, strong) IBOutlet NSSecureTextField *confirmPassword;

- (IBAction)continueClicked:(id)sender;
- (void)setPreferenceController:(PreferenceController*)prefsController;
- (void)updateStatusMessage:(NSNotification*)notif; 



@end