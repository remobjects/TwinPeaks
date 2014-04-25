//
//  TPGradientShared.h
//  TwinPeaks
//
//  Created by marc hoffman on 12/16/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTableView (Private)
- (void)_windowDidChangeKeyNotification:(NSNotification *)notification;
@end

typedef struct 
{
	CGFloat red1, green1, blue1, alpha1;
	CGFloat red2, green2, blue2, alpha2;
} _twoColorsType;

void _linearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _linearColorReleaseInfoFunction(void *info);

static const CGFunctionCallbacks linearFunctionCallbacks = { 0, &_linearColorBlendFunction, &_linearColorReleaseInfoFunction };
