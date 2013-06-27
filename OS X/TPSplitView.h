//
//  TPSplitView.h
//  TwinPeaks
//
//  Created by Alexander Karpenko on 3/9/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TPSplitView : NSSplitView 
#if MAC_OS_X_VERSION_10_6
<NSSplitViewDelegate>
#endif
{
    NSImageView *handleImage;
    CGFloat minTopLeft, minBottomRight;
    int priorityViewIndex;
    BOOL handleOnRight;
    
    BOOL bottomRightHidden;
    BOOL bottomRightIsFixed;
}

@property (assign) CGFloat minTopLeft, minBottomRight;
@property (assign, nonatomic) BOOL handleOnRight;
@property (readonly) BOOL bottomRightHidden;

- (void)hideBottomRight;
- (void)showBottomRight;

@end