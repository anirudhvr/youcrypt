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

@property (nonatomic, weak) IBOutlet NSTextField *name;
@property (nonatomic, weak) IBOutlet NSTextField *email;
@property (nonatomic, weak) IBOutlet NSTextField *msg;
@property (nonatomic, weak) IBOutlet NSSecureTextField *password;
@property (nonatomic, weak) IBOutlet NSSecureTextField *confirmPassword;

- (IBAction)continueClicked:(id)sender;
- (void)setPreferenceController:(PreferenceController*)prefsController;



@end