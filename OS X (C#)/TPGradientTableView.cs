using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	public class TPGradientTableView: NSTableView
	{
		public override NSMenu menuForEvent(NSEvent @event)
		{
			if (menu == null)
				return base.menuForEvent(@event);
				
			//  NSLog(@"menuForEvent:");
			//  Find which row is under the cursor
			this.window().makeFirstResponder(this);
			NSPoint menuPoint = this.convertPoint(@event.locationInWindow()) fromView(null);
			int row = this.rowAtPoint(menuPoint);
			if (row > -1)
			{
				bool currentRowIsSelected = this.selectedRowIndexes().containsIndex(row);
				if (!currentRowIsSelected)
					this.selectRowIndexes(NSIndexSet.indexSetWithIndex(row)) byExtendingSelection(false);
			}
			else
			{
				this.deselectAll(null);
			}
			if (this.numberOfSelectedRows() <= 0)
			{
				//  No rows are selected, so the table should be displayed with all items disabled
				NSMenu tableViewMenu = this.menu().copy();
				for (int i = 0; i < tableViewMenu.numberOfItems; i++)
					tableViewMenu.itemAtIndex(i).setEnabled(false);
				return tableViewMenu;
			}
			else
				return this.menu();
		}

		public override NSImage dragImageForRowsWithIndexes(NSIndexSet dragRows) tableColumns(NSArray tableColumns) @event(NSEvent dragEvent) offset(NSPointPointer dragImageOffset)
		{
			if (this.@delegate.respondsToSelector(__selector(tableView:needsImageForDraggingRowsWithIndexes:)))
			{
				return (this.@delegate as ITPGradientTableViewDelegate).tableView(this) needsImageForDraggingRowsWithIndexes(dragRows);
			}
			return base.dragImageForRowsWithIndexes(dragRows) tableColumns(tableColumns) @event(dragEvent) offset(dragImageOffset);
		}
	}

	public interface ITPGradientTableViewDelegate
	{
		void tableViewDidReceiveSpaceKey(NSTableView tableView);
		void tableViewDidReceiveDeleteKey(NSTableView tableView);
		NSImage tableView(NSTableView tableView) needsImageForDraggingRowsWithIndexes(NSIndexSet dragRows);
	}

	public static class Private {}
}
