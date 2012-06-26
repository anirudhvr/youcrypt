//
//  ListDirectoriesWindow.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoucryptDirectory.h"

@interface ListDirectoriesWindow : NSWindowController <NSTableViewDataSource, NSWindowDelegate, NSDraggingDestination> {
    IBOutlet NSMutableArray *directories;    
    IBOutlet NSTableView *table;
    IBOutlet NSTextField *dirName;          // The text field at the bottom.
}

@property (nonatomic, strong) NSString *directoriesListFile;
//@property (nonatomic, strong) NSMutableArray *directories;

- (id)initWithListFile:(NSString *)dList;

- (IBAction)doEncrypt:(id)sender;
- (IBAction)doOpen:(id)sender;
- (IBAction)doProps:(id)sender;
- (IBAction)selectRow:(id)sender;
- (IBAction)addNew:(id)sender;
- (IBAction)removeFS:(id)sender;
- (IBAction)windowWillClose:(NSNotification *)notification;

@end
