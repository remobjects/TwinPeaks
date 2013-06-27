//
//  Data Abstract for Cocoa
//
//  Copyright RemObjects Software. All rights reserved.
//
//  Using this code requires a valid license for Data Abstract 
//  which can be obtained at http://www.remobjects.com/da
//

#import "TPArrayHelpers.h"

@implementation NSArray (DAArrayHelpers)

- (NSDictionary *)arrayPartitionedByKey:(NSString *)key
{
	NSMutableDictionary *d = [NSMutableDictionary dictionary];
	for (id r in self)
	{
		NSString *group = [r valueForKey:key];
		if (!group) group = @"(null)";
		NSMutableArray *g = [d objectForKey:group];
		if (!g)
		{
			g = [NSMutableArray array];
			[d setObject:g forKey:group];
		}
		[g addObject:r];
	}
	return d;
}

- (NSArray *)sortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending
{
	return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:key ascending:ascending]]];
	
}

- (NSArray *)localizedCaseInsensitivelySortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending
{
	return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:key ascending:ascending selector:@selector(localizedCaseInsensitiveCompare:)]]];
}

#ifdef TP_DATAABSTRACT

- (NSArray *)selectChangedTables {
    
    NSMutableArray *changedTables = [NSMutableArray arrayWithCapacity:[self count]];
    for (DADataTable *table in self)
        if ([table hasChanges])
            [changedTables addObject:table];
    return changedTables;
}
#endif


@end
