using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	[IBObject]
	public class TPBusySheetController: NSWindowController
	{
		public override instancetype init()
		{
			this = base.initWithWindowNibName("TPBusySheetController");
			if (this != null)
			{
			}
			return this;
		}

		public override void windowDidLoad()
		{
			activity.startAnimation(this);
			cancel.setEnabled(allowCancel);
			cancel.setHidden(!allowCancel);
			message.setStringValue(messageText);
		}

		private void didEndSheet(NSWindow sheet) returnCode(int returnCode) contextInfo(void* contextInfo)
		{
			window.orderOut(window);
		}

		[IBOutlet] public NSTextField message;
		[IBOutlet] public NSProgressIndicator activity;
		[IBOutlet] public NSButton cancel;
		private NSString messageText;
		private bool allowCancel;
		private NSWindow window;

		public void showSheetForWindow(NSWindow aWindow) withMessage(NSString aMessage) allowCancel(bool aAllowCancel)
		{
			window = aWindow;
			messageText = aMessage;
			allowCancel = aAllowCancel;
			NSApp.beginSheet(window) modalForWindow(window) modalDelegate(this) didEndSelector(__selector(didEndSheet:returnCode:contextInfo:)) contextInfo(null);
		}

		public void hideSheet()
		{
			NSApp.endSheet(window);
			activity.stopAnimation(this);
		}

		public void showSheet()
		{
			NSApp.beginSheet(window) modalForWindow(window) modalDelegate(this) didEndSelector(__selector(didEndSheet:returnCode:contextInfo:)) contextInfo(null);
		}

		public void cancel(id sender)
		{
		}

		public void setMessageText(NSString text)
		{
			message.setStringValue(text);
		}
	}
}
