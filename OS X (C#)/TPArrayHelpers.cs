using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	[Category]
	public class NSArray_Helpers: NSArray
	{
		public NSDictionary arrayPartitionedByKey(NSString key)
		{
			NSMutableDictionary d = NSMutableDictionary.dictionary();
			foreach (id r in this)
			{
				NSString @group = r.valueForKey(key);
				if (@group == null)
					@group = "(null)";
				NSMutableArray g = d.objectForKey(@group);
				if (g == null)
				{
					g = NSMutableArray.array();
					d.setObject(g) forKey(@group);
				}
				g.addObject(r);
			}
			return d;
		}

		public NSArray sortedArrayUsingKey(NSString key) @ascending(bool @ascending)
		{
			return sortedArrayUsingDescriptors(NSArray.arrayWithObject(new NSSortDescriptor withKey(key) @ascending(@ascending)));
		}

		public NSArray localizedCaseInsensitivelySortedArrayUsingKey(NSString key) @ascending(bool @ascending)
		{
			return sortedArrayUsingDescriptors(NSArray.arrayWithObject(new NSSortDescriptor withKey(key) @ascending(@ascending) selector(__selector(localizedCaseInsensitiveCompare:))));
		}

		public id firstOrNil()
		{
			if (count > 0)
				return objectAtIndex(0);
			return null;
		}

		public static NSArray arrayWithSameValue(id value) count(NSInteger count)
		{
			var res = NSMutableArray.arrayWithCapacity(count);
			for (NSInteger i = 0; i < count; i++)
				res.addObject(value);
			return res;
		}
	}
	
	public static class NSArray_Helpers_TP_Mapped
	{
		public static NSArray<T> sortedArrayUsingKey<T>(this NSArray<T> @this,NSString key) @ascending(bool @ascending)
		{
			return sortedArrayUsingDescriptors(NSArray.arrayWithObject(new NSSortDescriptor withKey(key) @ascending(@ascending)));
		}
		
		public static  NSArray<T> localizedCaseInsensitivelySortedArrayUsingKey<T>(this NSArray<T> @this,NSString key) @ascending(bool @ascending)
		{
			return sortedArrayUsingDescriptors(NSArray.arrayWithObject(new NSSortDescriptor withKey(key) @ascending(@ascending) selector(__selector(localizedCaseInsensitiveCompare:))));
		}
	}
	
}