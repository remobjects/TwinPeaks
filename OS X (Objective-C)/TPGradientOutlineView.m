//
//  TPGradientOutlineView.m
//  TwinPeaks
//
//  Created by marc hoffman on 12/16/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import "TPGradientOutlineView.h"
#import "TPGradientShared.h"

@implementation TPGradientOutlineView

#include "TPGradientSharedCode.h"

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
