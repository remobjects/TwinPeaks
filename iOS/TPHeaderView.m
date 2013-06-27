//
//  HeaderView.m
//  Builds
//
//  Created by marc hoffman on 3/23/13.
//
//

#import "TPHeaderView.h"
#import "TPVersionHelpers.h"

@implementation TPHeaderView
{
    NSString *caption;
}

#define FONT_STYLE = 'UICTFontTextStyleSubhead1'; // UIFontTextStyleSubheadline1, cant link that in for iOS6?

+ (UIFont *)font
{
    if ([TPVersionHelpers isIOS7]) return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline1];
    return [UIFont boldSystemFontOfSize:15];
}

- (id)initWithWidth:(CGFloat)width caption:(NSString *)aCaption
{
    CGSize size = [aCaption sizeWithFont:[TPHeaderView font]];

    self = [super initWithFrame:CGRectMake(0, 0, width, size.height+10)];
    if (self)
    {
        self.opaque = NO;
        caption = aCaption;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIFont *font = [TPHeaderView font];
    CGSize size = [caption sizeWithFont:font];
    CGRect f = self.frame;

    CGFloat gray = 0;
    [[UIColor colorWithRed:gray green:gray blue:gray alpha:0.65] setFill];
    UIRectFill(self.bounds);

    [[UIColor whiteColor] set];
    [caption drawAtPoint:CGRectMake( (f.size.width-size.width)/2, (f.size.height-size.height)/2, 0, 0).origin withFont:font];
}

+ (CGFloat)headerHeight
{
    return [@"Xq" sizeWithFont:[self font]].height+10;
}

@end
