//
//  FeedbackSheetController.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "Contrib/JCSSheet/JCSSheetController.h"

@interface FeedbackSheetController : JCSSheetController

@property (atomic, strong) IBOutlet NSTextField *message;
@property (atomic, strong) IBOutlet NSButton *anonymize;
@property (atomic, strong) IBOutlet NSButton *logfiles;
@property (atomic, strong) IBOutlet NSTextField *progressMessage;

@property (atomic, strong) IBOutlet NSButton *isBug;
@property (atomic, strong) IBOutlet NSButton *isFeature;
@property (atomic, strong) IBOutlet NSButton *isSuggestion;


-(IBAction)send:(id)sender;
-(IBAction)cancel:(id)sender;

@end
