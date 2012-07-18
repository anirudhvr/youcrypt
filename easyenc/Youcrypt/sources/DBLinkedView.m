//
//  DBLinkedView.m
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "DBLinkedView.h"
#import "DBSetupSheetController.h"
#import "AppDelegate.h"
#import "ConfigDirectory.h"
#import "libFunctions.h"
@implementation DBLinkedView

@synthesize dbSetupSheet;
@synthesize selectedDBFolders;
@synthesize updateMessage;
@synthesize hiddenErrormsg;
@synthesize dbLoc;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        dbSetupSheet = [[DBSetupSheetController alloc] init];
    }
    
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(void) awakeFromNib
{
    selectedDBFolders = nil;
    NSString *str = [libFunctions locateDropboxFolder];
    if (str == nil) {
        [chooseDBFoldersToEncrypt setHidden:YES];
        [newYCFolderInDropbox setHidden:YES];
        [hiddenErrormsg setHidden:NO];
    } else {
        [dbLoc setStringValue:[NSString stringWithFormat:@"Dropbox folder found at '%@'", str]];
    }
    

}

- (IBAction)dbFolderCheckToggle:(id)sender
{
    if([chooseDBFoldersToEncrypt state]) {
        [self selectDBFoldersToEncrypt];
    }
}

- (void) selectDBFoldersToEncrypt
{
    [dbSetupSheet beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            DDLogVerbose(@"dbSetupSheet: Db setup sheet returned save");
            selectedDBFolders = dbSetupSheet.selected;
          // [self.window close];
        } else {
            DDLogVerbose(@"dbSetupSheet: Unknown return code");
        }
    }];  
}

-(IBAction)letsGo:(id)sender
{    
    if (selectedDBFolders == nil)
        selectedDBFolders = [[NSMutableSet alloc] init];
    
    if ([newYCFolderInDropbox state] == NSOnState) {
        NSString* newYCfolder = [[libFunctions locateDropboxFolder] stringByAppendingPathComponent:@"/YouCrypt"];
        if ([libFunctions mkdirRecursive:newYCfolder]) {
            [selectedDBFolders addObject:newYCfolder];
        }
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    int i = 1, count = [selectedDBFolders count];
    BOOL isDir;
    for (NSString *path in selectedDBFolders) {
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {                  
            // encrypt it if it'ns not already encrypted
            if (![[path pathExtension] isEqualToString:@"yc"]) {
                [theApp encryptFolder:path];
                [updateMessage setStringValue:[NSString stringWithFormat:@"Encrypting folder %d of %d (%@)",
                                               i++, count, path]];
            }
        }
    }

    [self.window close];
    
}

-(IBAction)notNow:(id)sender
{
    [self.window close];
}

@end
