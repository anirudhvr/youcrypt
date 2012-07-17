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
            DDLogVerbose(@"dbSetupSheet: DB Setup done");
          //  [self.window close];
        } else if (returnCode == kSheetReturnedCancel) {
            DDLogVerbose(@"dbSetupSheet: DB Setup cancelled :( ");
        } else {
            DDLogVerbose(@"dbSetupSheet: Unknown return code");
        }
    }];  
}

-(IBAction)letsGo:(id)sender
{
    // Link this to the queue when it's done
    NSLog(@"push folders here to the queue");
 
    
    if ([chooseDBFoldersToEncrypt state] == NSOnState) {
        [theApp encryptDropboxFolders];
    }
    
    
    if ([newYCFolderInDropbox state] == NSOnState) {
        NSString* newYCfolder = [NSString stringWithFormat:@"%@/YouCrypt", [libFunctions locateDropboxFolder]]; 
        if ([libFunctions mkdirRecursive:newYCfolder]) {
            [theApp encryptFolder:newYCfolder]; // XXX awakeFromNib issue
        }
    }
  
    
    [theApp.configDir firstRunSuccessful];
    [self.window close];
    
}

-(IBAction)notNow:(id)sender
{
    [theApp.configDir firstRunSuccessful];
    [self.window close];
}

@end
