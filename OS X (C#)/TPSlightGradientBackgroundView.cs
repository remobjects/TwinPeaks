using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	public class TPSlightGradientBackgroundView: NSView
	{
		private static NSImage imageFromCGImageRef(CGImageRef image)
		{
			NSRect imageRect = NSMakeRect(0D, 0D, 0D, 0D);
			CGContextRef imageContext = null;
			NSImage newImage = null;
			//  Get the image dimensions.
			imageRect.size.height = CGImageGetHeight(image);
			imageRect.size.width = CGImageGetWidth(image);
			//  Create a new image to receive the Quartz image data.
			newImage = NSImage.alloc().initWithSize(imageRect.size);
			newImage.lockFocus();
			//  Get the Quartz context and draw.
			imageContext = (NSGraphicsContext.currentContext().graphicsPort() as CGContextRef);
			CGContextDrawImage(imageContext, imageRect, image);
			newImage.unlockFocus();
			return newImage;
		}

		public override void drawRect(NSRect dirtyRect)
		{
			NSRect f = this.bounds();
			//  DEFINED: START ()  0.8
			//  DEFINED: END ()  0.9
			NSImage i = TPSlightGradientBackgroundView.createGradientImageWidth(f.size.width) height(f.size.height) fromColor(NSColor.colorWithCalibratedRed(0.8D) green(0.8D) blue(0.8D) alpha(1D)) toColor(NSColor.colorWithCalibratedRed(0.9D) green(0.9D) blue(0.9D) alpha(1D));
			i.drawInRect(f) fromRect(f) operation(NSCompositeCopy) fraction(1D);
		}

		public static NSImage createGradientImageWidth(CGFloat pixelsWide) height(CGFloat pixelsHigh) fromColor(NSColor fromColor) toColor(NSColor toColor)
		{
			CGImageRef theCGImage = null;
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			//  create the bitmap context
			CGContextRef gradientBitmapContext = CGBitmapContextCreate(null, (size_t)pixelsWide, (size_t)pixelsHigh, 8, 0, colorSpace, CGImageAlphaInfo.kCGImageAlphaNoneSkipFirst as CGBitmapInfo);
			//  define the start and end grayscale values (with the alpha, even though
			//  our bitmap context doesn't support alpha the gradient requires it)
			CGColorRef start = fromColor.CGColor();
			CGColorRef end = toColor.CGColor();
			CGColorRef[] colors = new [] {start, end};
			//  CGFloat locations[2] = { 0.0, 1.0 };
			CFArrayRef colorArray = CFArrayCreate(null, &colors, 2, null);
			//  create the CGGradient and then release the gray color space
			CGGradientRef grayScaleGradient = CGGradientCreateWithColors(null, colorArray, null);
			CGColorSpaceRelease(colorSpace);
			CFRelease(colorArray);
			//  create the start and end points for the gradient vector (straight down)
			CGPoint gradientStartPoint = CGPointZero;
			CGPoint gradientEndPoint = CGPointMake(pixelsWide / 2, pixelsHigh);
			//  draw the gradient into the gray bitmap context
			CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
			CGGradientRelease(grayScaleGradient);
			//  convert the context into a CGImageRef and release the context
			theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
			CGContextRelease(gradientBitmapContext);
			//  return the imageref containing the gradient
			NSImage theImage = this.imageFromCGImageRef(theCGImage);
			//  [NSImage imageWithCGImage:theCGImage];
			CGImageRelease(theCGImage);
			return theImage;
		}
	}
}
