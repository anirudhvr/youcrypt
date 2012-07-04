//
//  ListDirectoriesWindow.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoucryptDirectory.h"

@interface ListDirectoriesWindow : NSWindowController <NSWindowDelegate, NSDraggingDestination> {
    IBOutlet NSTableView *table;
    IBOutlet NSTextField *dirName;          // The text field at the bottom.
}

@property (atomic, strong) IBOutlet NSTableView *table;
- (IBAction)doEncrypt:(id)sender;
- (IBAction)doOpen:(id)sender;
- (IBAction)doProps:(id)sender;
- (IBAction)selectRow:(id)sender;
- (IBAction)addNew:(id)sender;
- (IBAction)removeFS:(id)sender;
- (IBAction)windowWillClose:(NSNotification *)notification;

@end
