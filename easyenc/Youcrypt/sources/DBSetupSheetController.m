//
//  DBSetupSheetController.m
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "DBSetupSheetController.h"
#import "Contrib/FileBrowser/FSBrowserCell.h"
#import "Contrib/FileBrowser/FSNode.h"
#import "AppDelegate.h"

@interface DBSetupSheetController ()

@end

@implementation DBSetupSheetController

@synthesize selected;

- (id)init
{
    if (!(self = [super initWithWindowNibName:@"DBSetup"])) {
        return nil; // Bail!
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)awakeFromNib {
    NSLog(@"AWAKE BROWSER");
    [_browser setCellClass:[FSBrowserCell class]];
    [_browser setColumnResizingType:NSBrowserUserColumnResizing];
    _rootNode = [[FSNode alloc] initWithPath:@"/Users/hr/Dropbox" isDirectory:YES];
    selected = [[NSMutableSet alloc] init];
}

#pragma mark NSBrowserDelegate
- (id)rootItemForBrowser:(NSBrowser *)browser {
    return _rootNode;    
}
- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    return [[(FSNode *)item children] count];
}
- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    return [[(FSNode *)item children] objectAtIndex:index];
}
- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    return ![(FSNode *)item isDirectory];
}
- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    return [(FSNode *)item displayName];
}
- (void)browser:(NSBrowser *)browser setObjectValue:(id)object forItem:(id)item {
    [(FSNode *)item setState:[object boolValue]];
}
- (void)browser:(NSBrowser *)browser willDisplayCell:(FSBrowserCell *)cell atRow:(NSInteger)row column:(NSInteger)column {
    NSLog(@"CALLED");
    NSIndexPath *indexPath = [browser indexPathForColumn:column];
    indexPath = [indexPath indexPathByAddingIndex:row];
    FSNode *node = [browser itemAtIndexPath:indexPath];
    BOOL isDir;
    if([[NSFileManager defaultManager] fileExistsAtPath:[node path] isDirectory:&isDir] && isDir) {
        [cell setTitle:[node displayName]];
        [cell setState:[node state]];
        if([cell state]) {
            [selected addObject:[node path]];
            
        } else {
            [selected removeObject:[node path]];
            
        }
    }
}

-(IBAction)save:(id)sender
{
    NSLog(@"Selected items:\n%@", selected);
    theApp.dropboxEncryptedFolders = selected;
    [self endSheetWithReturnCode:kSheetReturnedSave];
}

-(IBAction)cancel:(id)sender
{
    [self endSheetWithReturnCode:kSheetReturnedCancel];
}
@end