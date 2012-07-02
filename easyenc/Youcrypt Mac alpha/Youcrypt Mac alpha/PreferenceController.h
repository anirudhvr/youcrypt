//
//  PreferenceController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoxFSA.h"
#define MACOSX

@interface PreferenceController : NSWindowController <NSAlertDelegate,RKRequestDelegate> {
    
    NSTabView *tabView;

    // General preferences
    
    
    // Account preferences
    IBOutlet NSButton *linkBox;
    IBOutlet NSTextField *boxLinkStatus; 
    BoxFSA *boxClient;
    
    // Services preferences
    IBOutlet NSButton *checkbox;
    IBOutlet NSPathControl *dbLocation;
    BOOL changed;
    
    
    
}

static NSArray *openFiles();
NSString* systemCall(NSString *binary, NSArray *arguments);

@property (nonatomic) RKClient *client;
@property (nonatomic, strong) BoxFSA *boxClient;

- (IBAction)chooseDBLocation:(id)sender;
- (IBAction)saveButton:(id)sender;

- (IBAction)linkBoxAccount:(id)sender;
-(void)boxAuthDone:(NSAlert *)alert returnCode:(NSInteger)returnCode;

- (void) sendEmail;
@end