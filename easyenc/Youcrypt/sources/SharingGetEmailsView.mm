//
//  SharingWindowController.m
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "SharingGetEmailsView.h"
#import "AppDelegate.h"
#import "libFunctions.h"
#import "ListDirectoriesWindow.h"

@implementation SharingGetEmailsView

@synthesize emails;
@synthesize emailField;
@synthesize emailMessageField;
@synthesize shareButton;
@synthesize errmsg;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        emailStatus = NO;
    }
    
    return self;
}

- (void) setYoucryptDirectory:(YoucryptDirectory*)d
{
    dir = d;
}

- (void) awakeFromNib
{
    [emailField becomeFirstResponder];
    emailStatus = NO;
}

- (void)cancelOperation:(id)sender
{
    [emailField setStringValue:@""];
    [emailMessageField setStringValue:@""];
    [errmsg setStringValue:@""];
    [theApp.listDirectories.sharingPopover close];
}

- (IBAction)shareButtonClicked:(id)sender
{
    emailStatus = NO;
    NSString *e = [emailField stringValue];
    if (![libFunctions validateEmail:e]) {
        [errmsg setStringValue:@"Malformed email"];
        return;
    }
    
    if ([self sendEmail:e folder:dir]) {
        emailStatus = YES;
        [errmsg setStringValue:[NSString stringWithFormat:@"Successfully added user %@", e]];
        // Wait for a while for user to read msg
        [NSThread sleepForTimeInterval:1.0f]; 
        [theApp.listDirectories.sharingPopover close];
        
        [emailField setStringValue:@""];
        [emailMessageField setStringValue:@""];
        [errmsg setStringValue:@""];
        
        return;
    } else {
        [errmsg setStringValue:[NSString stringWithFormat:@"Error adding user %@", e]];
        return;
    }
    
//    [super goToNextView];
}

- (BOOL)sendEmail:(NSString*)emailaddress
           folder:(YoucryptDirectory*)dir
{
    [errmsg setStringValue:@"Not Implemented Yet"];
    emailStatus = NO;
    return NO;
}


@end
