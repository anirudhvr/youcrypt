//
//  ListDirTable.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ListDirectoriesWindow;

@interface ListDirTable : NSTableView {
    ListDirectoriesWindow *listDirObj;
}

@property (nonatomic, copy) ListDirectoriesWindow *listDirObj;

- (void) keyDown:(NSEvent *)theEvent;
- (void) setListDir:(ListDirectoriesWindow*)listDirObj;

@end
