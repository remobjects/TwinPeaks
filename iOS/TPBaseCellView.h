//
//  BugsBaseCell.h
//  Bugs
//
//  Created by marc hoffman on 1/10/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPBaseCellView : UIView 
{
#if RO_TARGET_DOES_ARC
    __unsafe_unretained UITableViewCell *cell;
#else
    UITableViewCell *cell;
#endif
    BOOL highlighted;
}

@property (assign) UITableViewCell *cell;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

//- (CGImageRef) createGradientImage;
//- (CGImageRef) createGradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh;

+ (UIImage *) gradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;
- (UIImage *) gradientImageWidth:(CGFloat)pixelsWide height:(CGFloat)pixelsHigh;
- (UIImage *) gradientImage;

- (UIColor *) gradientStartColor;
- (UIColor *) gradientStopColor;

@end
