//
//  TourController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/11/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TourController : NSWindowController {
    IBOutlet NSImageView *tourImage;
    int stage;
    IBOutlet NSButton *nextButton;
}

-(IBAction)cancel:(id)sender;
-(IBAction)next:(id)sender;
-(IBAction)showFirstRun:(id)sender;

@end
