//
//  SheetController.m
//  JCSSheetController_Example
//
//  Created by Abizer Nasir on 19/02/2011.
//  Copyright 2011 Jungle Candy Software. All rights reserved.
//

#import "VolumePropertiesSheetController.h"
#import "libFunctions.h"


@implementation VolumePropertiesSheetController

@synthesize sourcePath;
@synthesize mountPath;
@synthesize status;
@synthesize sp;
@synthesize mp;
@synthesize stat;

- (id)init {
    if (!(self = [super initWithWindowNibName:@"VolumePropertiesSheetController"])) {
        return nil; // Bail!
    }
    sp = [[NSString alloc] initWithString:@""];
    mp = [[NSString alloc] initWithString:@""];
    stat = [[NSString alloc] initWithString:@""];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
 
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void) sheetDidDisplay
{
    [sourcePath setStringValue:sp];
    [mountPath setStringValue:mp];
    [status setStringValue:stat];   
   
}
// Mark: -
// Mark: Action methods


- (void)okClicked:(id)sender {
    [self endSheetWithReturnCode:0];
}

// Mark: -
// Mark: Superclass overrides

- (void)sheetWillDisplay {
    [super sheetWillDisplay];
  
    
}

@end
