//
//  TPSplitView.m
//  TwinPeaks
//
//  Created by Alexander Karpenko on 3/9/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import "TPSplitView.h"


@implementation TPSplitView
-(void)awakeFromNib
{
    minTopLeft = 200;
    minBottomRight = 200;
    priorityViewIndex = 1;
    
    // divider style is thin by default
    [self setDividerStyle:NSSplitViewDividerStyleThin];
    
    // create and adjust handle image
    handleImage = [[NSImageView alloc] init];
    [handleImage setImageAlignment:NSImageAlignCenter];
    [handleImage setImageScaling:NSImageScaleNone];
    NSImage *i = [NSImage imageNamed:@"VerticalSplit"];
    [handleImage setImage:i];
    
    [self setHandleOnRight:NO];

    [self adjustSubviews];
    [self setDelegate:self];
}

@synthesize minTopLeft, minBottomRight, handleOnRight, bottomRightHidden;

- (void)setHandleOnRight:(BOOL)value
{
    handleOnRight = value;
    
    NSRect handleFrame = [handleImage frame];
    handleFrame.size.width = 20;
    handleFrame.size.height = 20;
    
    NSRect newBounds;
	newBounds.size.width = handleFrame.size.width;
	newBounds.size.height = handleFrame.size.height;
    if (handleOnRight)
    {
        NSView *rightSubview = [[self subviews] objectAtIndex:1];
        newBounds.origin.x =
        newBounds.origin.y = 5;
        [rightSubview addSubview:handleImage];
        [handleImage setAutoresizingMask:(NSViewMaxXMargin|NSViewMaxYMargin)];
    }
    else
    {
        NSView *leftSubview = [[self subviews] objectAtIndex:0];
        NSRect leftFrame = [leftSubview frame];
        newBounds.origin.x = leftFrame.size.width - handleFrame.size.width;
        newBounds.origin.y = 5;
        [leftSubview addSubview:handleImage];
        [handleImage setAutoresizingMask:(NSViewMinXMargin|NSViewMaxYMargin)];
    }
    newBounds.size.width = handleFrame.size.width;
    newBounds.size.height = handleFrame.size.height;
    [handleImage setFrame:newBounds];
    
}

- (CGFloat)dividerThickness
{
    if (bottomRightHidden) return 0;
    return [super dividerThickness];
}

- (void)hideBottomRight
{
    bottomRightHidden = YES;
    
    NSRect b = [self bounds];
    CGFloat pos = [self isVertical] ? b.size.width : b.size.height;
    [self setPosition:pos ofDividerAtIndex:0];
    
    [self adjustSubviews];
}

- (void)showBottomRight
{
    bottomRightHidden = NO;
    
    NSRect b = [self bounds];
    CGFloat pos = ([self isVertical] ? b.size.width : b.size.height)-minBottomRight;
    [self setPosition:pos ofDividerAtIndex:0];
    
    //[self adjustSubviews];
}

- (BOOL)mouseDownCanMoveWindow
{	
    return YES;	
}

- (NSColor *)dividerColor 
{
    return [NSColor darkGrayColor];
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex 
{
    return [handleImage convertRect:[handleImage bounds] toView:self];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (bottomRightHidden) return  splitView.bounds.size.width;
    if (proposedPosition < minTopLeft) proposedPosition = minTopLeft;
    if (proposedPosition > splitView.bounds.size.width-minBottomRight) proposedPosition = splitView.bounds.size.width-minBottomRight;
    return proposedPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    if (bottomRightHidden) return splitView.bounds.size.width;
    return minTopLeft;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    if (bottomRightHidden) return splitView.bounds.size.width;
    return splitView.bounds.size.width-minBottomRight;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    NSArray *subviews = [splitView subviews];
    
    if (bottomRightHidden)
    {
        [[subviews objectAtIndex:0] setFrameSize:[self frame].size];
        [[subviews objectAtIndex:1] setFrameSize:NSZeroSize];
        return;
    }
    
    
    BOOL isVertical = [splitView isVertical];
    
    CGFloat delta = isVertical ?
    (splitView.bounds.size.width - oldSize.width) :
    (splitView.bounds.size.height - oldSize.height);
    
    
    for (int i = 1; i >= 0; i--)
    {
        int viewIndexValue = i;
        
        NSView *view = [subviews objectAtIndex:viewIndexValue];
        NSSize frameSize = [view frame].size;
        
        CGFloat minLengthValue = i == 0 ? minTopLeft : (bottomRightHidden ? 0 : minBottomRight);
        
        if (isVertical)
        {
            frameSize.height = splitView.bounds.size.height;
            if (delta > 0 ||
                frameSize.width + delta >= minLengthValue)
            {
                frameSize.width += delta;
                delta = 0;
            }
            else if (delta < 0)
            {
                delta += frameSize.width - minLengthValue;
                frameSize.width = minLengthValue;
            }
        }
        else
        {
            frameSize.width = splitView.bounds.size.width;
            if (delta > 0 ||
                frameSize.height + delta >= minLengthValue)
            {
                frameSize.height += delta;
                delta = 0;
            }
            else if (delta < 0)
            {
                delta += frameSize.height - minLengthValue;
                frameSize.height = minLengthValue;
            }
        }
        
        [view setFrameSize:frameSize];
    }
    
    CGFloat offset = 0;
    CGFloat dividerThickness = [splitView dividerThickness];
    for (NSView *subview in subviews)
    {
        NSRect viewFrame = subview.frame;
        NSPoint viewOrigin = viewFrame.origin;
        viewOrigin.x = offset;
        [subview setFrameOrigin:viewOrigin];
        offset += viewFrame.size.width + dividerThickness;
    }
}

@end
