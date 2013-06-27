//
//  HeaderView.h
//  Builds
//
//  Created by marc hoffman on 3/23/13.
//
//

#import <UIKit/UIKit.h>

@interface TPHeaderView : UIView

- (id)initWithWidth:(CGFloat)width caption:(NSString *)caption;
+ (CGFloat)headerHeight;

@end
