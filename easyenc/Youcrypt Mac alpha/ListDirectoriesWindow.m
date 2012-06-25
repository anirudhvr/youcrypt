//
//  ListDirectoriesWindow.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListDirectoriesWindow.h"

@implementation ListDirectoriesWindow

@synthesize directoriesListFile;

- (id)init
{
    if (![super initWithWindowNibName:@"ListDirectoriesWindow"])
        return nil;
    return self;
}

- (id)initWithListFile:(NSString *)dList
{
    if (![super initWithWindowNibName:@"ListDirectoriesWindow"])
        return nil;
    directoriesListFile = dList;    
    directories = [NSKeyedUnarchiver unarchiveObjectWithFile:directoriesListFile];
    return self;    
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {        
        // Initialization code here.
        // Load list of directories from config file (dirs.plist)
    }    
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (directories)
        return directories.count;
    else {
        return 0;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (!directories)
        return nil;

    YoucryptDirectory *dirAtRow = [directories objectAtIndex:row];
    if (!dirAtRow)
        return nil;
    
    NSString *colId = [tableColumn identifier];
    if ([colId isEqualToString:@"path"])
        return dirAtRow.path;
    else if ([colId isEqualToString:@"mountedPath"])
        return dirAtRow.mountedPath;    
    else {
        return nil;
    }
}


- (void)awakeFromNib {
    
    NSTableColumn *col;
    
    col = [table tableColumnWithIdentifier:@"encrypt"];
    if (col) {
        NSButtonCell *proto = [[NSButtonCell alloc] init];
    }
    
//    table = 
//    
//    
//    NSTableColumn *checkboxColumn;
//    
//    checkboxColumn=[tableView tableColumnWithIdentifier:@"status"];
//    if (checkboxColumn)
//    {
//        NSButtonCell *protoCell;
//        
//        protoCell=[[NSButtonCell alloc] init];
//        [protoCell setButtonType:NSSwitchButton];
//        [protoCell setImagePosition:NSImageOnly];
//        [protoCell setTitle:@""];
//        [checkboxColumn setDataCell:protoCell];
//    }
//    [tableView setHeaderView:nil];
//    [tableView setAction:@selector(clicked:)];
//    [tableView setTarget:self];
//    [tableView reloadData];
}


- (IBAction)doEncrypt:(id)sender {
}

- (IBAction)doOpen:(id)sender {
    int a = 10;
    a ++;
}

- (IBAction)doProps:(id)sender {
    int a = 10;
    a ++;
}

- (IBAction)selectRow:(id)sender {

}

- (IBAction)addNew:(id)sender {
    
}

- (IBAction)removeFS:(id)sender {
    
}




@end
