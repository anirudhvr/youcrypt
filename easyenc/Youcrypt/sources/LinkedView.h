//
//  LinkedView.h
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

@class TourWizard;

@interface LinkedView : NSView
{
    IBOutlet LinkedView *previousView;
    IBOutlet LinkedView *nextView;
    IBOutlet NSTextField *message;
    
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *previousButton;
}

@property(nonatomic, strong)LinkedView *previousView, *nextView;
@property(nonatomic, strong) NSTextField *message;
@property(nonatomic, strong) TourWizard *tourWizard;

- (void)goToNextView;
- (void)goToPrevView;

@end
