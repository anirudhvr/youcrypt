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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusMessage:) name:YC_KEYOPS_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusMessage:) name:YC_SERVEROPS_NOTIFICATION object:nil];
}

- (void)updateStatusMessage:(NSNotification*)notif
{
    NSDictionary *userInfo = notif.userInfo;
    [msg setStringValue:[NSString stringWithFormat:@"%@\n%@", [msg stringValue], [userInfo objectForKey:@"message"]]];
    [msg display];
    [NSThread sleepForTimeInterval:0.1f];
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
        
        [preferenceController setPreference:YC_USEREMAIL value:[email stringValue]];
        [preferenceController setPreference:YC_USERREALNAME value:[name stringValue]];
        
        // This is critical now because encrypt/decrypt/restore get the pp from the passphrase manager
        NSError *err;
        if (![theApp.passphraseManager setPassphrase:[password stringValue] error:&err]) {
            DDLogError(@"Setting passphrase during registraiton failed: %@", [err localizedDescription]);
            return;
        }
        
        if (![theApp setupCM:[password stringValue]
            createIfNotFound:YES createAccount:YES pushKeys:YES]) {
            [msg setStringValue:@"Unknown error creating credentials."];
            return;
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // Removes from all queues
    
    [super goToNextView];
    
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
