//
//  SharingWindowController.h
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinkedView.h"
#import "YoucryptDirectory.h"

@interface SharingGetEmailsView : LinkedView
{
    YoucryptDirectory *dir;
    BOOL emailStatus;
}

@property (nonatomic, strong) NSMutableArray *emails;
@property (nonatomic, strong) IBOutlet NSTextField *emailField;
@property (nonatomic, strong) IBOutlet NSTextField *emailMessageField;
@property (nonatomic, strong) IBOutlet NSTextField *errmsg;
@property (nonatomic, strong) IBOutlet NSButton *shareButton;


- (void) setYoucryptDirectory:(YoucryptDirectory*)d;
- (BOOL)sendEmail:(NSString*)emailaddress
           folder:(YoucryptDirectory*)dir;
- (IBAction)shareButtonClicked:(id)sender;

@end

