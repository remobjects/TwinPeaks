//
//  OAGradientTableView.m
//  Bugs
//
//  Created by marc hoffman on 1/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TPGradientTableView.h"
#import "TPGradientShared.h"

@implementation TPGradientTableView

#include "TPGradientSharedCode.h"

//
// http://forums.macrumors.com/showthread.php?t=166469
//
- (NSMenu*)menuForEvent:(NSEvent*)event
{
	if ([self menu])
		return [super menuForEvent:event];

	//NSLog(@"menuForEvent:");
	//Find which row is under the cursor
	[[self window] makeFirstResponder:self];
	NSPoint menuPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	int row = [self rowAtPoint:menuPoint];
	
	if (row > -1)
	{
		BOOL currentRowIsSelected = [[self selectedRowIndexes] containsIndex:row];
		if (!currentRowIsSelected)
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	}
	else
	{
		[self deselectAll:nil];
	}

	
	if ([self numberOfSelectedRows] <=0)
	{
        //No rows are selected, so the table should be displayed with all items disabled
		NSMenu* tableViewMenu = [[self menu] copy];
		int i;
		for (i=0;i<[tableViewMenu numberOfItems];i++)
			[[tableViewMenu itemAtIndex:i] setEnabled:NO];
		return tableViewMenu;
	}
	else
		return [self menu];
}

- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns event:(NSEvent *)dragEvent offset:(NSPointPointer)dragImageOffset
{
	if ([self.delegate respondsToSelector:@selector(tableView:needsImageForDraggingRowsWithIndexes:)])
	{
		return [(id<TPGradientTableViewDelegate>)self.delegate tableView:self needsImageForDraggingRowsWithIndexes:dragRows];
	}
	return [super dragImageForRowsWithIndexes:dragRows 
								 tableColumns:tableColumns 
										event:dragEvent 
									   offset:dragImageOffset];
}

@end


@implementation TPGradientTableView (Private)

@end