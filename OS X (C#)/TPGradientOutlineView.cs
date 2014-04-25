using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	public class TPGradientOutlineView: NSOutlineView
	{
		public override NSImage dragImageForRowsWithIndexes(NSIndexSet dragRows) tableColumns(NSArray tableColumns) @event(NSEvent dragEvent) offset(NSPointPointer dragImageOffset)
		{
			if (this.@delegate.respondsToSelector(__selector(tableView:needsImageForDraggingRowsWithIndexes:)))
			{
				return (this.@delegate as ITPGradientTableViewDelegate).tableView(this) needsImageForDraggingRowsWithIndexes(dragRows);
			}
			return base.dragImageForRowsWithIndexes(dragRows) tableColumns(tableColumns) @event(dragEvent) offset(dragImageOffset);
		}
	}
}
