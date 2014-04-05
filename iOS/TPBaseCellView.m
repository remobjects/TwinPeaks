//
//  BugsBaseCell.m
//  Bugs
//
//  Created by marc hoffman on 1/10/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import "TPBaseCellView.h"

@implementation TPBaseCellView

@synthesize cell = cell;
@synthesize highlighted = highlighted;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)setHighlighted:(BOOL)aHighlighted
{
	if (aHighlighted != highlighted)
	{
		highlighted = aHighlighted;
		[self setNeedsDisplay];
	}
}

- (UIColor *) gradientStartColor
{
	return [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];	
}

- (UIColor *) gradientStopColor
{
	return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}

+ (UIImage *) createGradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor
{
    CGImageRef theCGImage = NULL;
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
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
    CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
    
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);
	
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
    
    // return the imageref containing the gradient
	UIImage *theImage = [UIImage imageWithCGImage:theCGImage];
	CGImageRelease(theCGImage);
    return theImage;
}

- (UIImage *) createGradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh
{
	return [[self class] createGradientImageWidth:pixelsWide height:pixelsHigh fromColor:[self gradientStartColor] toColor:[self gradientStopColor]];
}

- (UIImage *) createGradientImage
{
	CGRect f = [self bounds];
	return [self createGradientImageWidth:f.size.width height:f.size.height];
}	

+ (UIImage *) gradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;
{
	return [self createGradientImageWidth:pixelsWide height:pixelsHigh fromColor:fromColor toColor:toColor];
}

- (UIImage *) gradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh
{
	return [self createGradientImageWidth:pixelsWide height:pixelsHigh];
}

- (UIImage *) gradientImage
{
	return [self createGradientImage];
}




@end
