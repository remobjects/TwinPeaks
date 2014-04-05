//
//  CaptionAndTextCellView.h
//  Bugs
//
//  Created by marc hoffman on 3/19/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPBaseCellView.h"

@interface TPCaptionAndTextCellView : TPBaseCellView 
{
	NSString *caption;
	NSString *text;
	CGFloat textAlpha;
	UIColor *color;
	BOOL centered;
}

@property (assign) CGFloat textAlpha;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *text;
@property (strong) UIColor *color;
@property (assign) BOOL centered;

+ (CGFloat)cellHeightForText:(NSString *)text;
+ (CGFloat)cellHeightForCaption:(NSString *)caption text:(NSString *)text;
+ (CGFloat)cellHeightForCaption:(NSString *)caption text:(NSString *)text width:(CGFloat)width;

@end
