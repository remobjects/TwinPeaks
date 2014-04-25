using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	public class TPWindowManager: NSObject
	{
		protected NSMutableDictionary singleWindows;

		private static TPWindowManager _sharedInstance;
		public static TPWindowManager sharedInstance()
		{
			if (_sharedInstance == null)
				_sharedInstance = new TPWindowManager();
			return _sharedInstance;
		}

		public NSWindowController uniqueWindowControllerForClass(Class @class)
		{
			if (!(singleWindows != null))
				singleWindows = NSMutableDictionary.dictionaryWithCapacity(5);
			NSWindowController w = singleWindows.objectForKey(@class);
			if (!(w != null))
			{
				w = @class.alloc().init();
				singleWindows.setObject(w) forKey(@class);
			}
			return w;
		}

		public void showWindowForClass(Class @class)
		{
			NSWindowController w = this.uniqueWindowControllerForClass(@class);
			w.showWindow(null);
		}
	}
}
