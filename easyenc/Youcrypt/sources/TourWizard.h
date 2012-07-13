//
//  TourWizard.h
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>

@class LinkedView;

@interface TourWizard : NSWindowController
{
    IBOutlet LinkedView *currentView;
    CATransition *transition;

}

@property(nonatomic, strong) LinkedView *currentView;

- (IBAction)nextView:(id)sender;
- (IBAction)previousView:(id)sender;

@end
