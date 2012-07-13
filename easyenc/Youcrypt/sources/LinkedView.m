//
//  LinkedView.m
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//


#import "LinkedView.h"


@implementation LinkedView

@synthesize  previousView, nextView;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void) awakeFromNib
{
    [self setWantsLayer:YES];
    [previousButton setEnabled:(previousView != nil)];
    [nextButton setEnabled:(nextView != nil)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
