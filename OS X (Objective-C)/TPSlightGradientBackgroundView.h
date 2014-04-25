//
//  TPSlightGradientBackgroundView.h
//  TwinPeaks
//
//  Created by marc hoffman on 3/15/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TPSlightGradientBackgroundView : NSView 
{

}

+ (NSImage *) createGradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh fromColor:(NSColor *)fromColor toColor:(NSColor *)toColor;

@end
