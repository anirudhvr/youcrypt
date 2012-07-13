//
//  DBLinkedView.h
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "LinkedView.h"

@class DBSetupSheetController;

@interface DBLinkedView : LinkedView
{
    IBOutlet NSButton *newYCFolderInDropbox;
    IBOutlet NSButton *chooseDBFoldersToEncrypt;
    DBSetupSheetController *dbSetupSheet;
}

@property (nonatomic, strong) DBSetupSheetController *dbSetupSheet;
-(IBAction)dbFolderCheckToggle:(id)sender;
-(void)selectDBFoldersToEncrypt;

@end
