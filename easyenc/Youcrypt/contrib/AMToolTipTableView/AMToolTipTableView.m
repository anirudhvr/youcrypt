//
//  AMToolTipTableView.h
//
//  Created by Andreas on Fri Oct 18 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//
//	Use this code for whatever you like. It is free.
//
//  2011-03-27 Andreas Mayer
//	- placated the analyzer with additional brackets


#import "AMToolTipTableView.h"


@interface AMToolTipTableView (Private)
- (NSString *)_amKeyForColumn:(NSInteger)columnIndex row:(NSInteger)rowIndex;
@end


@implementation AMToolTipTableView

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
	// create region list
	regionList = [[NSMutableDictionary alloc] initWithCapacity:20];
	return self;
}

- (void)awakeFromNib
{
	// create region list
	regionList = [[NSMutableDictionary alloc] initWithCapacity:20];
}

/*
- (void)dealloc
{
	[regionList release];
	[super dealloc];
}
 */

- (void)reloadData
{
	// we have to invalidate the region list here
	[regionList removeAllObjects];
	[self removeAllToolTips];
	[super reloadData];
}

- (NSRect)frameOfCellAtColumn:(NSInteger)columnIndex row:(NSInteger)rowIndex
{
	// this cell is apparently displayed, so we need to add a region for it
	NSNumber *toolTipTag;

	NSRect result = [super frameOfCellAtColumn:columnIndex row:rowIndex];

	// check if cell is already in the list
	NSString *cellKey = [self _amKeyForColumn:columnIndex row:rowIndex];
	if ((toolTipTag = [regionList objectForKey:cellKey])) {
		// remove old region
		[self removeToolTip:[toolTipTag intValue]];
	}
	// add new region
	[regionList setObject:[NSNumber numberWithInteger:[self addToolTipRect:result owner:self userData:(void*)cellKey]] forKey:cellKey];
	return [super frameOfCellAtColumn:columnIndex row:rowIndex];
}

- (NSString *)_amKeyForColumn:(NSInteger)columnIndex row:(NSInteger)rowIndex
{
	return [NSString stringWithFormat:@"%d,%d", rowIndex, columnIndex];
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)data
{
	// ask our data source for the tool tip
	if ([[self dataSource] respondsToSelector:@selector(tableView:toolTipForTableColumn:row:)]) {
		if ([self rowAtPoint:point] >= 0)
			return [(id <AMTableViewToolTipDataSource>)[self dataSource] tableView:self toolTipForTableColumn:[[self tableColumns] objectAtIndex:[self columnAtPoint:point]] row:[self rowAtPoint:point]];
	}
	return nil;
}


@end
