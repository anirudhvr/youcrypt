//
//  TourController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/11/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "TourController.h"
#import "AppDelegate.h"

@interface TourController ()

@end

@implementation TourController

- (id)init
{
    if (![super initWithWindowNibName:@"Tour"])
        return nil;
    
    return self;
}

- (void) awakeFromNib
{
    NSImage *boxLogo = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/box-logo.png"]];
    [tourImage setImage:boxLogo]; 
    stage = 1;
}

- (void) cancel:(id)sender
{
    [self.window close];
}

- (void) next:(id)sender
{
    stage++;
    NSLog(@"IN NEXT: STAGE : %d",stage);

    NSString *picture;
    switch (stage) {
        case 2:
            picture = @"/Add.png";
            break;
        case 3:
            [nextButton setTitle:@"Finish"];
            [nextButton setAction:@selector(showFirstRun:)];
            picture = @"/Key.png";
            break;
        default:
            break;
    }
    NSImage *boxLogo = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:picture]];
    [tourImage setImage:boxLogo];
    
}

-(IBAction)showFirstRun:(id)sender
{
    [self.window close];
    [theApp showFirstRun];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
