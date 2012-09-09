//
//  AboutController.m
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/16/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "AboutController.h"

@interface AboutController ()

@end

@implementation AboutController

- (id)init
{
    if (![super initWithWindowNibName:@"About"])
        return nil;
    return self;
}

-(void) awakeFromNib
{
    [version setStringValue:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    DDLogVerbose(@"Awake from nib : ABOUT");
}


- (IBAction)ok:(id)sender
{
    [self.window close];
}

- (IBAction) showTerms:(id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://youcrypt.com/alpha/TOS"]];
   
}

@end
