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
    if ([TPVersionHelpers isIOS7]) return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    return [UIFont boldSystemFontOfSize:15];
}

+ (NSDictionary *)attributes
{
    return @{NSFontAttributeName: [self font], NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (id)initWithWidth:(CGFloat)width caption:(NSString *)aCaption
{
    self = [super initWithFrame:CGRectMake(0, 0, width, [TPHeaderView headerHeight])];
    if (self)
    {
        self.opaque = NO;
        caption = aCaption;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSDictionary *attributes = [TPHeaderView attributes];
    CGSize size = [caption sizeWithAttributes:attributes];
    CGRect f = self.frame;

    CGFloat gray = 0;
    [[UIColor colorWithRed:gray green:gray blue:gray alpha:0.65] setFill];
    UIRectFill(self.bounds);

    [caption drawAtPoint:CGRectMake( (f.size.width-size.width)/2, (f.size.height-size.height)/2, 0, 0).origin withAttributes:attributes];
}

+ (CGFloat)headerHeight
{
    return [@"Xq" sizeWithAttributes:[self attributes]].height+10;
}

@end
