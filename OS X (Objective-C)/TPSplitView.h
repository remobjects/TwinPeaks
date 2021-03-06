//
//  TPSplitView.h
//  TwinPeaks
//
//  Created by Alexander Karpenko on 3/9/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TPSplitView;

@protocol TPSplitViewDelegate <NSObject>

- (void)splitViewDidResizeSubviews:(TPSplitView *)splitView;

@end

@interface TPSplitView : NSSplitView <NSSplitViewDelegate>
{
    NSImageView *handleImage;
    BOOL handleOnRight;
}

@property (assign) CGFloat minTopLeft, minBottomRight;
@property (assign) CGFloat maxTopLeft, maxBottomRight;

@property (assign) int priorityViewIndex;

@property (readonly) BOOL secondaryViewIsHidden;

/*@property (assign, nonatomic) BOOL handleOnRight;
- (void)hideBottomRight;
- (void)showBottomRight;*/

- (CGFloat)positionOfDividerAtIndex:(NSInteger)index;

@property (weak) id<TPSplitViewDelegate> delegate2;

@end