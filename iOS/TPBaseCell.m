//
//  BaseCell.m
//  Dough
//
//  Created by marc hoffman on 4/23/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import "TPBaseCell.h"
#import "TPBaseCellView.h"
#import "TPVersionHelpers.h"


@implementation TPBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style viewClass:(Class)class
{
    self = [super initWithStyle:style reuseIdentifier:[class description]];
    if (self)
    {
        view = [[class alloc] initWithFrame:self.contentView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:view];
        if (![TPVersionHelpers isIOS7])
        {
            [self setBackgroundGradient];
        }
        if ([view respondsToSelector:@selector(setCell:)]) [(TPBaseCellView *)view setCell:self];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style viewClass:(Class)class size:(CGSize)size
{
    self = [super initWithStyle:style reuseIdentifier:[class description]];
    if (self)
    {
        view = [[class alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:view];
        [self setBackgroundGradient];
    }
    return self;
}

@synthesize view = view;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) setBackgroundGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;
{
    CGRect f = [self frame];
    UIImage *i;
    if (![TPVersionHelpers isIOS7])
    {
        i = [TPBaseCellView gradientImageWidth:f.size.width height:f.size.height fromColor:fromColor toColor:toColor];
    }
    else
    {
        i = [TPBaseCellView gradientImageWidth:f.size.width height:f.size.height fromColor:fromColor toColor:fromColor];
    }
#if RO_TARGET_DOES_ARC
    UIImageView *b = [[UIImageView alloc] initWithImage:i];
#else
    UIImageView *b = [[[UIImageView alloc] initWithImage:i] autorelease];
#endif
    [self setBackgroundView:b];
}

- (void) setSelectedBackgroundGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;
{
    CGRect f = [self frame];
    UIImage *i = [TPBaseCellView gradientImageWidth:f.size.width height:f.size.height fromColor:fromColor toColor:toColor];
#if RO_TARGET_DOES_ARC
    UIImageView *b = [[UIImageView alloc] initWithImage:i];
#else
    UIImageView *b = [[[UIImageView alloc] initWithImage:i] autorelease];
#endif
    [self setSelectedBackgroundView:b];
}

- (void) setBackgroundGradient;
{
    [self setBackgroundGradientFromColor:[(TPBaseCellView *)[self view] gradientStartColor] toColor:[(TPBaseCellView *)[self view] gradientStopColor]];
}



@end
