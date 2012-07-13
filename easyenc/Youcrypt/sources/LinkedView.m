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
@synthesize message;

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
    [message setStringValue:@""];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
