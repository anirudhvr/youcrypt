//
//  FeedbackSheetController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "Contrib/JCSSheet/JCSSheetController.h"

@interface FeedbackSheetController : JCSSheetController

@property (nonatomic, weak) IBOutlet NSTextField *message;
@property (nonatomic, weak) IBOutlet NSButton *anonymize;
@property (nonatomic, weak) IBOutlet NSButton *logfiles;
@property (nonatomic, weak) IBOutlet NSTextField *progressMessage;

-(IBAction)send:(id)sender;
-(IBAction)cancel:(id)sender;

@end
