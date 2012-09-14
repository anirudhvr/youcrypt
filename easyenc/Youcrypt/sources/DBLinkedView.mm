//
//  DBLinkedView.m
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "DBLinkedView.h"
#import "DBSetupSheetController.h"
#import "libFunctions.h"
#import "AppDelegate.h"
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
    if ([str isEqualToString:@""]) {
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
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    
    if ([newYCFolderInDropbox state] == NSOnState) {
        NSString *dbloc = [libFunctions locateDropboxFolder];
        if ([dbloc isNotEqualTo:@""]) {
            NSString* newYCfolder = [dbloc stringByAppendingPathComponent:@"YouCrypt"];
            
            if ([fm fileExistsAtPath:[newYCfolder stringByAppendingPathExtension:ENCRYPTED_DIRECTORY_EXTENSION] isDirectory:&isDir]) {
                DDLogError(@"Folder %@.%@ already exists and is encrypted?", newYCfolder, ENCRYPTED_DIRECTORY_EXTENSION);
            } else if ( ([fm fileExistsAtPath:newYCfolder isDirectory:&isDir] && isDir) ||
                       ([libFunctions mkdirRecursive:newYCfolder]) ) {
                [selectedDBFolders addObject:newYCfolder];
            } else {
                DDLogError(@"Could not create folder %@", newYCfolder);
            }
                
        }
    }
    
    long i = 1, count = [selectedDBFolders count];
    for (NSString *path in selectedDBFolders) {
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {                  
            // encrypt it if it'ns not already encrypted
            if (![[path pathExtension] isEqualToString:ENCRYPTED_DIRECTORY_EXTENSION]) {
                [theApp encryptFolder:path];
                [updateMessage setStringValue:[NSString stringWithFormat:@"Encrypting folder %ld of %ld (%@)",
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
