//
//  TPSlightGradientBackgroundView.m
//  TwinPeaks
//
//  Created by marc hoffman on 3/15/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import "TPSlightGradientBackgroundView.h"

/*@interface NSColor(CGColor)
- (CGColorRef)CGColor;
@end

@implementation NSColor(CGColor)

- (CGColorRef)CGColor 
{
    CGColorSpaceRef colorSpace = [[self colorSpace] CGColorSpace];
    NSInteger componentCount = [self numberOfComponents];
    CGFloat *components = (CGFloat *)calloc(componentCount, sizeof(CGFloat));
    [self getComponents:components];
    CGColorRef color = CGColorCreate(colorSpace, components);
    free((void*)components);
    return color;
}

@end*/

@implementation TPSlightGradientBackgroundView

+(NSImage*) imageFromCGImageRef:(CGImageRef)image
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil;
	
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
	
    // Create a new image to receive the Quartz image data.
#if __has_feature(objc_arc)
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
#else
    newImage = [[[NSImage alloc] initWithSize:imageRect.size] autorelease];
#endif
    [newImage lockFocus];
	
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext]
								  graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];
	
    return newImage;
}

+ (NSImage *) createGradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh fromColor:(NSColor *)fromColor toColor:(NSColor *)toColor
{
    CGImageRef theCGImage = NULL;
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, kCGImageAlphaNoneSkipFirst);
    
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
	CGColorRef start = [fromColor CGColor];
	CGColorRef end = [toColor CGColor];
    CGColorRef colors[2] = { start, end };
	
	//CGFloat locations[2] = { 0.0, 1.0 };
	
	CFArrayRef colorArray = CFArrayCreate (NULL, (void *)&colors, 2, NULL);    
    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColors(NULL/*colorSpace*/, colorArray, NULL/*locations*/);
    CGColorSpaceRelease(colorSpace);
	CFRelease(colorArray);
    
    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(pixelsWide/2, pixelsHigh);
    
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);
	
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
    
    // return the imageref containing the gradient
	NSImage *theImage = [self imageFromCGImageRef:theCGImage];//[NSImage imageWithCGImage:theCGImage];
	CGImageRelease(theCGImage);
    return theImage;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect f = [self bounds];
	
#define START 0.8
#define END 0.9
	
	NSImage *i = [TPSlightGradientBackgroundView createGradientImageWidth:f.size.width 
																   height:f.size.height 
																fromColor:[NSColor colorWithCalibratedRed:START green:START blue:START alpha:1.0] 
																  toColor:[NSColor colorWithCalibratedRed:END green:END blue:END alpha:1.0]];
	[i drawInRect:f fromRect:f operation:NSCompositeCopy fraction:1.0];
}



@end
