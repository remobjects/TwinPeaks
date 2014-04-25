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
    _priorityViewIndex = 1;
    _minTopLeft = 200;
    _minBottomRight = 200;
    
    _maxTopLeft = INT_MAX;
    _maxBottomRight = INT_MAX;
    
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

/*- (void)hideBottomRight
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
    CGFloat pos = ([self isVertical] ? b.size.width : b.size.height)-_minBottomRight;
    [self setPosition:pos ofDividerAtIndex:0];
    
    //[self adjustSubviews];
}*/

- (BOOL)mouseDownCanMoveWindow
{	
    return YES;	
}

- (CGFloat)dividerThickness
{
    //if ([self isVertical])
    //    NSLog(@"dividerThickness: %f", [self secondaryViewIsHidden] ? 0 : [super dividerThickness]);
    
    //if ([self secondaryViewIsHidden]) return 0;
    return [super dividerThickness];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return [self secondaryViewIsHidden];
}

- (NSColor *)dividerColor
{
    return [NSColor darkGrayColor];
}

- (CGFloat)positionOfDividerAtIndex:(NSInteger)index
{
    if ([self isVertical])
        return [[[self subviews] objectAtIndex:index] frame].size.width;
    else
        return [[[self subviews] objectAtIndex:index] frame].size.height;
}

- (CGFloat)totalSize
{
    if ([self isVertical])
        return [self frame].size.width;
    else
        return [self frame].size.height;
}

- (BOOL)secondaryViewIsHidden
{
    if (_priorityViewIndex == 0)
    {
        //NSLog(@"positionOfDividerAtIndex: %d, %d", _priorityViewIndex, [self positionOfDividerAtIndex:0] >= [self totalSize]);
        return [self positionOfDividerAtIndex:0] >= [self totalSize];
    }
    else if (_priorityViewIndex == 1)
    {
        //if ([self isVertical])
        //    NSLog(@"secondaryViewIsHidden: %d", [self positionOfDividerAtIndex:0] <= 0);
        return [self positionOfDividerAtIndex:0] <= 0;
    }
    return NO;
}

- (BOOL)bottomRightHidden
{
    //NSLog(@"bottomRightHidden _priorityViewIndex: %d, %d", _priorityViewIndex, [self secondaryViewIsHidden]);
    return _priorityViewIndex == 0 && [self secondaryViewIsHidden];
}

- (BOOL)topLeftHidden
{
    //NSLog(@"topLeftHidden _priorityViewIndex: %d, %d", _priorityViewIndex, [self secondaryViewIsHidden]);
    return _priorityViewIndex == 1 && [self secondaryViewIsHidden];
}



- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
    return [handleImage convertRect:[handleImage bounds] toView:self];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
    //if (![self isVertical]) NSLog(@"constrainSplitPosition:%f ofSubviewAt:%ld", proposedPosition, dividerIndex);
    //if (_priorityViewIndex == 1 && [self secondaryViewIsHidden]) return splitView.bounds.size.width;
    //if (_priorityViewIndex == 0 && [self secondaryViewIsHidden]) return 0;
    if (proposedPosition < _minTopLeft) proposedPosition = _minTopLeft;
    if (proposedPosition > [self totalSize]-_minBottomRight) proposedPosition = [self totalSize]-_minBottomRight;

    if (proposedPosition > _maxTopLeft) proposedPosition = _maxTopLeft;
    if (proposedPosition < [self totalSize]-_maxBottomRight) proposedPosition = [self totalSize]-_maxBottomRight;
    
    //NSLog(@"new = %f", proposedPosition);
    return proposedPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    //if (![self isVertical]) NSLog(@"constrainMinCoordinate:%f ofSubviewAt:%ld (result=%f)", proposedMin, dividerIndex, _minTopLeft);
    //if (_priorityViewIndex == 1 && [self secondaryViewIsHidden]) return [self totalSize];
    //if (_priorityViewIndex == 0 && [self secondaryViewIsHidden]) return 0;
    return _minTopLeft;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    //if (![self isVertical]) NSLog(@"constrainMaxCoordinate:%f ofSubviewAt:%ld (result=%f)", proposedMax, dividerIndex, [self totalSize]-_minBottomRight);
    //if (_priorityViewIndex == 1 && [self secondaryViewIsHidden]) [self totalSize];
    //if (_priorityViewIndex == 1 && [self secondaryViewIsHidden]) [self totalSize];
    return [self totalSize]-_minBottomRight;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    NSArray *subviews = [splitView subviews];
    
    BOOL isVertical = [splitView isVertical];

    if ([self bottomRightHidden])
    {
        CGSize size0 = [self frame].size;
        CGSize size1 = [self frame].size;
        if (isVertical)
        {
            size0.width--;
            size1.width = 1;
        }
        else
        {
            size0.height--;
            size1.height = 1;
        }
        [[subviews objectAtIndex:0] setFrameSize:size0];
        [[subviews objectAtIndex:1] setFrameSize:size1];
        return;
    }
    if ([self topLeftHidden])
    {
        [[subviews objectAtIndex:1] setFrameSize:[self frame].size];
        [[subviews objectAtIndex:0] setFrameSize:NSZeroSize];
        return;
    }
    
    CGFloat delta = isVertical ? (splitView.bounds.size.width - oldSize.width) : (splitView.bounds.size.height - oldSize.height);
    
    int start = (_priorityViewIndex == 1) ? 1 : 0;
    int end = (_priorityViewIndex == 1) ? -1 : 2;
    int direction = (_priorityViewIndex == 1) ? -1 : +1;
    
    for (int i = start; i != end; i += direction)
    {
        NSView *view = [subviews objectAtIndex:i];
        NSSize frameSize = [view frame].size;

        CGFloat size;
        if (isVertical)
        {
            frameSize.height = splitView.bounds.size.height;
            size = frameSize.width;
        }
        else
        {
            frameSize.width = splitView.bounds.size.width;
            size = frameSize.height;
        }
        
        CGFloat minLengthValue = i == 0 ? _minTopLeft : _minBottomRight;

        if (delta > 0 || size + delta >= minLengthValue)
        {
            size += delta;
            delta = 0;
        }
        else if (delta < 0)
        {
            delta += size - minLengthValue;
            size = minLengthValue;
        }
        
        if (isVertical)
            frameSize.width = size;
        else
            frameSize.height = size;
        
        [view setFrameSize:frameSize];
    }
    
    CGFloat offset = 0;
    CGFloat dividerThickness = [self dividerThickness];

    for (int i = 0; i < [subviews count]; i++)
    {
        NSView *view = [subviews objectAtIndex:i];
        NSRect viewFrame = view.frame;
        
        NSPoint viewOrigin = viewFrame.origin;
        if (isVertical)
        {
            viewOrigin.x = offset;
            [view setFrameOrigin:viewOrigin];
            offset += viewFrame.size.width + dividerThickness;
        }
        else
        {
            viewOrigin.y = offset;
            [view setFrameOrigin:viewOrigin];
            offset += viewFrame.size.height + dividerThickness;
        }
    }
    
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    if (_delegate2 != nil && [_delegate2 respondsToSelector:@selector(splitViewDidResizeSubviews:)])
        [_delegate2 splitViewDidResizeSubviews:self];
}


@end
