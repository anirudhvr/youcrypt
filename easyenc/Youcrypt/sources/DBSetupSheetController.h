//
//  DBSetupSheetController.h
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/12/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "JCSSheetController.h"
#import "Contrib/FileBrowser/FSNode.h"

@interface DBSetupSheetController : JCSSheetController <NSBrowserDelegate> {
    IBOutlet NSBrowser *_browser;
    FSNode *_rootNode;
    NSMutableSet *selected;
}

@property (nonatomic,strong) NSMutableSet *selected;

-(IBAction)save:(id)sender;
-(IBAction)cancel:(id)sender;
@end