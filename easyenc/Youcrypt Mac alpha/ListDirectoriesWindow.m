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
    if ([colId isEqualToString:@"alias"])
        return dirAtRow.alias;
    else if ([colId isEqualToString:@"mountedPath"])
        return dirAtRow.mountedPath;    
    else {
        return nil;
    }
}

- (void)awakeFromNib {
    [table registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}


- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pb = [info draggingPasteboard];
    
    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    
    NSPasteboard *pb = [info draggingPasteboard];
    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];

        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            YoucryptDirectory *nd = [[YoucryptDirectory alloc] init];
            nd.path = path;
            nd.alias = [path lastPathComponent];
            nd.mounted = NO;
            [directories addObject:nd];
            [table reloadData];
            return YES;
        }
    }
    return NO;
}


//- (void)awakeFromNib {
//    
//    NSTableColumn *col;
//    
//    col = [table tableColumnWithIdentifier:@"encrypt"];
//    if (col) {
//        NSButtonCell *proto = [[NSButtonCell alloc] init];
//    }
//    
////    table = 
////    
////    
////    NSTableColumn *checkboxColumn;
////    
////    checkboxColumn=[tableView tableColumnWithIdentifier:@"status"];
////    if (checkboxColumn)
////    {
////        NSButtonCell *protoCell;
////        
////        protoCell=[[NSButtonCell alloc] init];
////        [protoCell setButtonType:NSSwitchButton];
////        [protoCell setImagePosition:NSImageOnly];
////        [protoCell setTitle:@""];
////        [checkboxColumn setDataCell:protoCell];
////    }
////    [tableView setHeaderView:nil];
////    [tableView setAction:@selector(clicked:)];
////    [tableView setTarget:self];
////    [tableView reloadData];
//}


- (IBAction)doEncrypt:(id)sender {
}

- (IBAction)doOpen:(id)sender {
}

- (IBAction)doProps:(id)sender {
}

- (IBAction)selectRow:(id)sender {
    YoucryptDirectory *dir = [directories objectAtIndex:[sender clickedRow]];
    [dirName setStringValue:dir.path];
}

- (IBAction)addNew:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // NO files.
    [openDlg setCanChooseFiles:NO];
    
    // YES, directories.
    [openDlg setCanChooseDirectories:YES];
    
    // Sure, as many as you want.
    [openDlg setAllowsMultipleSelection:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        
        // Loop through all the files and process them.
        for( int i = 0; i < [files count]; i++ )
        {
            YoucryptDirectory *nd = [[YoucryptDirectory alloc] init];
            nd.path = [files objectAtIndex:i];
            nd.alias = [nd.path lastPathComponent];
            [directories addObject:nd];
            // Do something with the filename.
        }
        [table reloadData];
    }

}

- (IBAction)removeFS:(id)sender {
    NSInteger row = [table selectedRow];
    if (row != -1) {
        [directories removeObjectAtIndex:row];
        [table reloadData];
    }
    
}

- (IBAction)windowWillClose:(NSNotification *)notification {
    [NSKeyedArchiver archiveRootObject:directories toFile:directoriesListFile];    
}



@end
