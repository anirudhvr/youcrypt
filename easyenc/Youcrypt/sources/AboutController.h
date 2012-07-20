//
//  AboutController.h
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/16/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutController : NSWindowController
{
    IBOutlet NSTextField *version;
}

- (IBAction) showTerms:(id) sender;


@end
