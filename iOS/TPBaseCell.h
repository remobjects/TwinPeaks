//
//  BaseCell.h
//  Dough
//
//  Created by marc hoffman on 4/23/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TPBaseCell : UITableViewCell
{
    UIView *view;
}

@property (readonly) id view;

- (id)initWithStyle:(UITableViewCellStyle)style viewClass:(Class)class;
- (id)initWithStyle:(UITableViewCellStyle)style viewClass:(Class)class size:(CGSize)size;

- (void) setBackgroundGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;
- (void) setBackgroundGradient;

- (void) setSelectedBackgroundGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

@end
