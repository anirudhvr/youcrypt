//
//  ListDirectoriesWindow.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListDirectoriesWindow.h"
#import "AppDelegate.h"

@implementation ListDirectoriesWindow

@synthesize table;

- (id)init
{
    if (![super initWithWindowNibName:@"ListDirectoriesWindow"])
        return nil;
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {        
    }    
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.    
}


- (void)awakeFromNib {
    [table setDataSource:theApp];
    [table registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (IBAction)doEncrypt:(id)sender {
}

- (IBAction)doOpen:(id)sender {
    YoucryptDirectory *dir = [theApp.directories objectAtIndex:[sender clickedRow]];
    [theApp openEncryptedFolder:[dir path]];
}

- (IBAction)doProps:(id)sender {
}

- (IBAction)selectRow:(id)sender {
    if ([sender clickedRow] < [theApp.directories count]) {
        YoucryptDirectory *dir = [theApp.directories objectAtIndex:[sender clickedRow]];
        [dirName setStringValue:dir.path];
    }
}

- (IBAction)addNew:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // NO files, YES directories and knock yourself out[TM] with as many as you want
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:YES];
    
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        for( int i = 0; i < [files count]; i++ )
            [theApp encryptFolder:[files objectAtIndex:i]];
        [table reloadData];
    }

}

- (IBAction)removeFS:(id)sender {
    NSInteger row = [table selectedRow];
    if (row != -1) {        
        [table reloadData];
    }
    
}



@end
