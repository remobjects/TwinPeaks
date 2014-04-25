using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	public class TPBaseSheetController: NSWindowController
	{
		public override instancetype init()
		{
			NSString name = this.@class().className().substringToIndex(this.@class().className().length() - 10);
			return base.initWithWindowNibName(name);
		}

		public override void awakeFromNib()
		{
			this.validate(null);
		}

		private void didEndSheet(NSWindow sheet) returnCode(int returnCode) contextInfo(void* contextInfo)
		{
			this.window().orderOut(this.window());
			retainedSelf = null;
		}

		private NSDragOperation draggingEntered(INSDraggingInfo sender)
		{
			return NSDragOperationCopy;
		}

		private NSDragOperation draggingUpdated(INSDraggingInfo sender)
		{
			return NSDragOperationCopy;
		}

		private bool prepareForDragOperation(INSDraggingInfo sender)
		{
			return true;
		}

		private TPBaseSheetController retainedSelf;

		public bool validated { get; set; }
		public __weak id @delegate { get; set; }
		public NSWindow parentWindow { get; private set; }

		public void showForWindow(NSWindow aWindow)
		{
			parentWindow = aWindow;
			retainedSelf = this;
			NSApp.beginSheet(this.window()) modalForWindow(aWindow) modalDelegate(this) didEndSelector(__selector(didEndSheet:returnCode:contextInfo:)) contextInfo(null);
		}

		public void toggleView(NSView view) andView(NSView view2) enabled(bool enabled)
		{
			if (enabled)
			{
				view.animator().setAlphaValue(1D);
				view2.animator().setAlphaValue(1D);
			}
			else
			{
				view.animator().setAlphaValue(0.25D);
				view2.animator().setAlphaValue(0.25D);
			}
		}

		public bool validateView(NSView view) forCondition(bool condition)
		{
			if (!condition)
			{
				this.validated = false;
				NSShadow shadow = NSShadow.alloc().init();
				shadow.setShadowColor(NSColor.redColor());
				shadow.setShadowOffset(NSMakeSize(0, 0));
				shadow.setShadowBlurRadius(4D);
				view.setShadow(shadow);
			}
			else
			{
				view.setShadow(null);
			}
			return condition;
		}

		public void validate(id sender)
		{
			this.validated = true;
		}

		public void cancel(id sender)
		{
			NSApp.endSheet(this.window());
		}

		public void enableAsFileDragDestination()
		{
			this.window.registerForDraggedTypes(NSArray.arrayWithObjects(NSFilesPromisePboardType, NSFilenamesPboardType, null));
		}

		public NSArray getFilenamesForDragOperation(INSDraggingInfo info)
		{
			//  ToDo: also support NSFileNamesPromisePboardType!
			NSPasteboard pboard = info.draggingPasteboard();
			return pboard.propertyListForType(NSFilenamesPboardType);
		}
	}
}
