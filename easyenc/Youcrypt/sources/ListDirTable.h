//
//  ListDirTable.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "contrib/AMToolTipTableView/AMToolTipTableView.h"

@class ListDirectoriesWindow;

@interface ListDirTable : AMToolTipTableView {
    ListDirectoriesWindow *listDirObj;
    NSImageView *backgroundImageView; // The imageview under the table
    NSImage *defaultImage;
    NSImage *otherImage;

}

@property (nonatomic, copy) ListDirectoriesWindow *listDirObj;

- (void) keyDown:(NSEvent *)theEvent;
- (void) setListDir:(ListDirectoriesWindow*)listDirObj;
- (void) setImageViewUnderTable:(NSImageView*)imgView;

@end
