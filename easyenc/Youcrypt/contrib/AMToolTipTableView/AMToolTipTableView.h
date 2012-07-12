//
//  AMToolTipTableView.h
//
//  Created by Andreas on Fri Oct 18 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//
//	Use this code for whatever you like. It is free.
//
//	This subclass of NSTableView allows you to display different tool tips
//	for each cell in the table.
//
//	When the table view needs to display a tool tip, it asks it's data source
//	for it. So you need to implement tableView:toolTipForTableColumn:row: in
//	your table's data source. See declaration below.
//
//  AMTableViewToolTipDataSource is an informal protocol. Nothing bad happens if
//	you don't implement it's method. But in that case you wouldn't need this
//	subclass anyway. :}


#import <Cocoa/Cocoa.h>


@interface AMToolTipTableView : NSTableView {
	NSMutableDictionary *regionList;
}

- (void)awakeFromNib;


@end


@protocol AMTableViewToolTipDataSource

- (NSString *)tableView:(NSTableView *)aTableView toolTipForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

@end