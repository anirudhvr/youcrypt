//
//  SharingController.m
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "SharingGetEmailsView.h"
#import "libFunctions.h"
#import "LinkedView.h"
#import "AppDelegate.h"

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
    [self.window close];
}

- (void) setDirPath:(NSString*)path
{
    dirPath = [NSString stringWithString:path];
}

- (void)updateStatusMessage:(NSNotification*)notification
{
    [errmsg setStringValue:[[notification userInfo] objectForKey:@"message"]];
    [NSThread sleepForTimeInterval:0.5f];
}

- (IBAction)shareButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusMessage:) name:YC_KEYOPS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusMessage:) name:YC_SERVEROPS_NOTIFICATION object:nil];
    
    emailStatus = NO;
    NSString *e = [emailField stringValue];
    NSString *m = [emailMessageField stringValue];
    if (![libFunctions validateEmail:e]) {
        [errmsg setStringValue:@"Malformed email"];
        return;
    }
    
    if (dirPath == nil) {
        [errmsg setStringValue:@"Unknown folder shared!"];
        return;
    }
    
    if ([theApp performShare:e message:m dirPath:dirPath]) {
        [errmsg setStringValue:[NSString stringWithFormat:@"Successfully added user %@", e]];
        [errmsg display];
        // Wait for a while for user to read msg
        [NSThread sleepForTimeInterval:1.0f]; 
        
        [emailField setStringValue:@""];
        [emailMessageField setStringValue:@""];
        [errmsg setStringValue:@""];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.window close];
    }
    
    
//    [super goToNextView];
}

@end
