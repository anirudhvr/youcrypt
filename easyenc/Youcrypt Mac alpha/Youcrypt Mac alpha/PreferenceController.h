//
//  PreferenceController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferenceController : NSWindowController {
    
    NSTabView *tabView;

    // General preferences
    
    
    // Account preferences
    
    
    // Services preferences
    IBOutlet NSButton *checkbox;
    IBOutlet NSPathControl *dbLocation;
    BOOL changed;
    
    
    
}

static NSArray *openFiles();
NSString* systemCall(NSString *binary, NSArray *arguments);

- (IBAction)chooseDBLocation:(id)sender;
- (IBAction)saveButton:(id)sender;
@end