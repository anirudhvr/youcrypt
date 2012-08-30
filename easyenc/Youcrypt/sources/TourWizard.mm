//
//  TourWizard.m
//  Youcrypt
//
//  Created by Anirudh Ramachandran on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "TourWizard.h"
#import "LinkedView.h"

@implementation TourWizard

@synthesize message;
@synthesize currentView;

- (id)init
{
    self = [super initWithWindowNibName:@"TourWizard"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)awakeFromNib
{
    NSView *contentView = [[self window] contentView];
    
    [[NSColor grayColor] set]; 
    [contentView setFrame:NSMakeRect(10, 10, [contentView bounds].size.width - 20, 500)];
    
    [contentView setWantsLayer:YES];
    [contentView addSubview:[self currentView]];
    
    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromLeft];
    
    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
    [contentView setAnimations:ani];
    
    if (currentView) {
        currentView.tourWizard = self;
        [message setStringValue:[currentView.message stringValue]];
    }
    
}

- (void)setCurrentView:(LinkedView*)newView
{
    if (!currentView) {
        currentView = newView;
        [message setStringValue:[currentView.message stringValue]];
        return;
    }
    NSView *contentView = [[self window] contentView];
    [[contentView animator] replaceSubview:currentView with:newView];
    currentView = newView;
    [message setStringValue:[currentView.message stringValue]];
}

- (IBAction)nextView:(id)sender
{
    (void)sender;
    if (![[self currentView] nextView]) return;
    [transition setSubtype:kCATransitionFromRight];
    [self setCurrentView:[[self currentView] nextView]];
}

- (IBAction)previousView:(id)sender
{
    (void)sender;
    if (![[self currentView] previousView]) return;
    [transition setSubtype:kCATransitionFromLeft];
    [self setCurrentView:[[self currentView] previousView]];
}


@end
