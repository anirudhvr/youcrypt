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

-(BOOL)setListDirWindow:(ListDirectoriesWindow*)ldw
{
    _listDirWindow = ldw;
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
    NSString *m = [emailMessageField stringValue];
    if (![libFunctions validateEmail:e]) {
        [errmsg setStringValue:@"Malformed email"];
        return;
    }
    
    if (!_listDirWindow) {
        [errmsg setStringValue:@"Sharing not correctly initialized"];
        return;
    }
    
    if ([_listDirWindow performShare:e message:m]) {
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


@end
