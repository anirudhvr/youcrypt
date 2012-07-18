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
    IBOutlet NSTextField *hiddenErrormsg;
    IBOutlet NSTextField *dbLoc;
    DBSetupSheetController *dbSetupSheet;
}

@property (nonatomic, strong) DBSetupSheetController *dbSetupSheet;
@property (nonatomic, strong) NSMutableSet *selectedDBFolders;
@property (nonatomic, strong) IBOutlet NSTextField *updateMessage;
@property (nonatomic, strong)     IBOutlet NSTextField *hiddenErrormsg;
@property (nonatomic, strong) IBOutlet NSTextField *dbLoc;


-(IBAction)dbFolderCheckToggle:(id)sender;
-(void)selectDBFoldersToEncrypt;

-(IBAction)letsGo:(id) sender;
-(IBAction)notNow:(id) sender;


@end
