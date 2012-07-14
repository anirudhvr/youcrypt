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
    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
    [previousButton setEnabled:(previousView != nil)];
    [nextButton setEnabled:(nextView != nil)];
    [message setStringValue:@""];
    
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    // Drawing code here.
//    [[NSColor darkGrayColor] set];
  //  NSRectFill(rect);
    //[self setAlphaValue:0.1];

}

-(BOOL) isOpaque
{
    return NO;
}



@end
