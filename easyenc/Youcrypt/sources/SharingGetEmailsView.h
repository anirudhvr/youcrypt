//
//  SharingController.h
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinkedView.h"

@interface SharingGetEmailsView : LinkedView
{
    BOOL emailStatus;
    NSString *dirPath;
}

@property (nonatomic, strong) NSMutableArray *emails;
@property (nonatomic, strong) IBOutlet NSTextField *emailField;
@property (nonatomic, strong) IBOutlet NSTextField *emailMessageField;
@property (nonatomic, strong) IBOutlet NSTextField *errmsg;
@property (nonatomic, strong) IBOutlet NSButton *shareButton;


- (IBAction)shareButtonClicked:(id)sender;
- (void) setDirPath:(NSString*)path;
- (void)updateStatusMessage:(NSNotificationCenter*)notification;

@end

