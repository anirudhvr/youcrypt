//
//  LinkedView.h
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

@interface LinkedView : NSView
{
    IBOutlet LinkedView *previousView;
    IBOutlet LinkedView *nextView;
    
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *previousButton;
}

@property(nonatomic, strong)LinkedView *previousView, *nextView;


@end
