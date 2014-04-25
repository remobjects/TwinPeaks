//
//  TPWindowManager.m
//  TwinPeaks
//
//  Created by marc hoffman on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TPWindowManager.h"

@implementation TPWindowManager

static TPWindowManager *instance;

+ (TPWindowManager *)sharedInstance
{
    if (!instance) instance = [[self alloc] init];
    return instance;
}

- (NSWindowController *)uniqueWindowControllerForClass:(Class)class
{
    if (!singleWindows) singleWindows = [[NSMutableDictionary dictionaryWithCapacity:5] retain];
	NSWindowController *w = [singleWindows objectForKey:class];
	if (!w)
	{
		w = [[[class alloc] init] autorelease];
		[singleWindows setObject:w forKey:class];
	}
	return w;
}

- (void)showWindowForClass:(Class)class
{
	NSWindowController *w = [self uniqueWindowControllerForClass:class];
	[w showWindow:nil];
}

@end
