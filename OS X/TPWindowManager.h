//
//  TPWindowManager.h
//  TwinPeaks
//
//  Created by marc hoffman on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPWindowManager : NSObject
{
    NSMutableDictionary *singleWindows;
}

+ (TPWindowManager *)sharedInstance;

- (NSWindowController *)uniqueWindowControllerForClass:(Class)class;
- (void)showWindowForClass:(Class)class;

@end
