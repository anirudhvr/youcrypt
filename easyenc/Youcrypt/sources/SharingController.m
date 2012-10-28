//
//  SharingController.m
//  Youcrypt
//
//  Created by avr on 10/27/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "SharingController.h"
#import "SharingGetEmailsView.h"

@interface SharingController ()

@end

@implementation SharingController

@synthesize sharingView;


-(id)init
{
	if (!(self = [super initWithWindowNibName:@"SharingWindow"])){
         return nil;
         DDLogVerbose(@"ERROR: cannot alloc sharingController");
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) setWindowAttributes:(NSString*)title
                  folderPath:(NSString*)dirPath
{
    [[self window] setTitle:title];
    [sharingView setDirPath:dirPath];
    
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"Called");
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
