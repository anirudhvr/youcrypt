//
//  VolumePropertiesSheetControllerWindowController.h
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 7/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JCSSheetController.h"


@interface VolumePropertiesSheetController : JCSSheetController {
    NSString *sp;
    NSString *mp;
    NSString *stat;
}

@property (nonatomic, weak) IBOutlet NSTextField *sourcePath;
@property (nonatomic, weak) IBOutlet NSTextField *mountPath;
@property (nonatomic, weak) IBOutlet NSTextField *status;

@property (nonatomic, copy) NSString *sp;
@property (nonatomic, copy) NSString *mp;
@property (nonatomic, copy) NSString *stat;


-(IBAction)okClicked:(id)sender;
@end
