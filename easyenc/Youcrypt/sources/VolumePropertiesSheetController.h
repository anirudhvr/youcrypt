//
//  VolumePropertiesSheetControllerWindowController.h
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 7/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Contrib/JCSSheet/JCSSheetController.h"


@interface VolumePropertiesSheetController : JCSSheetController {
    NSString *sp;
    NSString *mp;
    NSString *stat;
}

@property (atomic, strong) IBOutlet NSTextField *sourcePath;
@property (atomic, strong) IBOutlet NSTextField *mountPath;
@property (atomic, strong) IBOutlet NSTextField *status;
@property (atomic, strong) IBOutlet NSTextField *mountedDate;
@property (atomic, strong) IBOutlet NSTextField *openedByUser;
@property (atomic, strong) IBOutlet NSButton *openMountedPath;

@property (nonatomic, copy) NSString *sp;
@property (nonatomic, copy) NSString *mp;
@property (nonatomic, copy) NSString *stat;
@property (nonatomic, copy) NSString *openedby;
@property (nonatomic, copy) NSString *mntdate;


-(IBAction)okClicked:(id)sender;
-(IBAction)openMountedPath:(id)sender;
@end
