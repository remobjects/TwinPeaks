using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	public class TPLoginWindowController: NSWindowController
	{
		public override instancetype init()
		{
			this = base.initWithWindowNibName("TPLoginWindowController");
			if (this != null)
			{
			}
			return this;
		}

		public override void awakeFromNib()
		{
			if (loginNameTemp != null)
				loginNameField.setStringValue(loginNameTemp);
			if (passwordTemp != null)
				passwordField.setStringValue(passwordTemp);
			if (loginNameTemp != null)
				this.window.makeFirstResponder(passwordField);
			else
				this.window.makeFirstResponder(loginNameField);
		}

		private void didEndSheet(NSWindow sheet) returnCode(int returnCode) contextInfo(void* contextInfo)
		{
			this.window().orderOut(parentWindow);
		}

		protected NSTextField loginNameField;
		protected NSTextField passwordField;
		protected bool done;
		protected NSWindow parentWindow;
		protected NSString loginNameTemp;
		protected NSString passwordTemp;

		protected NSString loginName
		{
			get
			{
				return loginNameField.stringValue();
			}

			set
			{
				loginNameTemp = value;
				loginNameField.setStringValue(value);
			}
		}

		protected NSString password
		{
			get
			{
				return passwordField.stringValue();
			}

			set
			{
				passwordTemp = value;
				passwordField.setStringValue(value);
			}
		}

		public void onLoginClick(id sender)
		{
			done = true;
			NSApp.stopModal();
		}

		public void onCancelClick(id sender)
		{
			done = false;
			NSApp.stopModal();
		}

		public bool promptForLogin(NSWindow aParentwindow)
		{
			done = false;
			parentWindow = aParentwindow;
			if (aParentwindow.isVisible())
			{
				NSApp.beginSheet(this.window()) modalForWindow(aParentwindow) modalDelegate(this) didEndSelector(__selector(didEndSheet:returnCode:contextInfo:)) contextInfo(null);
				try
				{
					NSApp.runModalForWindow(this.window());
				}
				finally
				{
					NSApp.endSheet(this.window());
					this.window().orderOut(parentWindow);
				}
			}
			else
			{
				NSModalSession s = NSApp.beginModalSessionForWindow(this.window());
				this.window().display();
				try
				{
					NSApp.runModalForWindow(this.window());
				}
				finally
				{
					NSApp.endModalSession(s);
					this.window().close();
				}
			}
			return done;
		}
	}
}
