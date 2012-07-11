//
//  GmailSheetController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "Contrib/JCSSheet/JCSSheetController.h"

@class PreferenceController;

@interface GmailSheetController : JCSSheetController {
    PreferenceController *preferenceController;
}

@property (nonatomic, weak) IBOutlet NSTextField *username;
@property (nonatomic, weak) IBOutlet NSSecureTextField *password;


- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (void) setPreferenceController:(PreferenceController*)prefsController;
@end

