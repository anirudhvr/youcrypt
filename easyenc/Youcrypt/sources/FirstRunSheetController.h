//
//  FirstRunSheetController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Contrib/JCSSheet/JCSSheetController.h"

@class PreferenceController;

@interface FirstRunSheetController : JCSSheetController {
    PreferenceController *preferenceController;

}

@property (nonatomic, weak) IBOutlet NSTextField *name;
@property (nonatomic, weak) IBOutlet NSTextField *email;
@property (nonatomic, weak) IBOutlet NSTextField *message;
@property (nonatomic, weak) IBOutlet NSSecureTextField *password;
@property (nonatomic, weak) IBOutlet NSSecureTextField *confirmPassword;

- (IBAction)saveClicked:(id)sender;
- (void)setPreferenceController:(PreferenceController*)prefsController;


@end
