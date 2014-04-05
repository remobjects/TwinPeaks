//
//  OAGradientTableView.h
//  Bugs
//
//  Created by marc hoffman on 1/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TPGradientTableView : NSTableView {

}

@end

@protocol TPGradientTableViewDelegate

@optional

- (void)tableViewDidReceiveSpaceKey:(NSTableView *)tableView;
- (void)tableViewDidReceiveDeleteKey:(NSTableView *)tableView;
- (NSImage *)tableView:(NSTableView *)tableView needsImageForDraggingRowsWithIndexes:(NSIndexSet *)dragRows;

@end

