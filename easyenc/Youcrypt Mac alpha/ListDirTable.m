//
//  ListDirTable.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "ListDirTable.h"
#import "AppDelegate.h"
#import "ListDirectoriesWindow.h"


@implementation ListDirTable

@synthesize listDirObj;


- (void) setListDir:(ListDirectoriesWindow *)listDirObject
{
    listDirObj = listDirObject;
}

- (void) keyDown:(NSEvent *)theEvent;
{
    NSLog(@"KEY! : %d",theEvent.keyCode);
    switch (theEvent.keyCode) {
        case 125: // down
        case 126: // up
            [listDirObj setStatusToSelectedRow:[listDirObj.table selectedRow]];
            break;
        case 117: // delete
            [listDirObj removeFS:listDirObj.window];
            break;
        case 36: // enter
            [listDirObj doOpenProxy:[listDirObj.table selectedRow]];
            break;
        default:
            break;
        
	}    
   [super keyDown:theEvent];			
}

@end
