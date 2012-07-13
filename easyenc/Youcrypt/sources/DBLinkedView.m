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
            NSLog(@"DB Setup done");
            [theApp encryptDropboxFolders];
          //  [self.window close];
        } else if (returnCode == kSheetReturnedCancel) {
            NSLog(@"DB Setup cancelled :( ");
        } else {
            NSLog(@"Unknown return code");
        }
    }];  
}
@end
