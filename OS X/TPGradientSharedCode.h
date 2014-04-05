// NSObject

- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_windowDidChangeKeyNotification:)
												 name:NSWindowDidResignKeyNotification object:newWindow];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWindowDidBecomeKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_windowDidChangeKeyNotification:)
												 name:NSWindowDidBecomeKeyNotification object:newWindow];
}

// NSTableView

- (void)highlightSelectionInClipRect:(NSRect)rect;
{
	/*NSColor *evenColor = [[NSColor colorWithCalibratedRed:0.95 green: 0.95 blue: 0.95 alpha: 1.0] retain];
	// empirically determined color, matches iTunes etc. = [NSColor colorWithCalibratedRed:0.929 green:0.953 blue:0.996 alpha:1.0];
	NSColor *oddColor  = [NSColor whiteColor];
	
	//float rowHeight = [delegate tableView:<#(NSTableView *)tableView#> heightOfRow:<#(NSInteger)row#>
	//15;//[self rowHeight];// + [self intercellSpacing].height;
	NSRect visibleRect = [self visibleRect];
	NSRect highlightRect;
	
	highlightRect.origin = NSMakePoint(
									   NSMinX(visibleRect),
									   (int)(NSMinY(rect)/rowHeight)*rowHeight);
	highlightRect.size = NSMakeSize(
									NSWidth(visibleRect),
									rowHeight);// - [self intercellSpacing].height);
	
	while (NSMinY(highlightRect) < NSMaxY(rect))
	{
		NSRect clippedHighlightRect
		= NSIntersectionRect(highlightRect, rect);
		int row = (int)
		((NSMinY(highlightRect)+rowHeight/2.0)/rowHeight);
		NSColor *rowColor
		= (0 == row % 2) ? evenColor : oddColor;
		[rowColor set];
		NSRectFill(clippedHighlightRect);
		highlightRect.origin.y += rowHeight;
	}

	// ====== */
	
	// Take the color apart
	NSColor *alternateSelectedControlColor = [NSColor alternateSelectedControlColor];
	CGFloat hue, saturation, brightness, alpha;
	[[alternateSelectedControlColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getHue:&hue
																				saturation:&saturation 
																				brightness:&brightness 
																					 alpha:&alpha];
	
	// Create synthetic darker and lighter versions
	NSColor *lighterColor = [NSColor colorWithDeviceHue:hue
											 saturation:MAX(0.0, saturation-.12) 
											 brightness:MIN(1.0, brightness+0.10) // .30 
												  alpha:alpha];
	NSColor *darkerColor = [NSColor colorWithDeviceHue:hue
											saturation:MIN(1.0, (saturation > .04) ? saturation+0.12 : 0.0) 
											brightness:MAX(0.0, brightness-0.10)  //0.045
												 alpha:alpha];
	
	/* If this view isn't key, use the gray version of the dark color.
	Note that this varies from the standard gray version that NSCell
	returns as its highlightColorWithFrame: when the cell is not in a
	key view, in that this is a lot darker. Mike and I think this is
	justified for this kind of view -- if you're using the dark
	selection color to show the selected status, it makes sense to
	leave it dark. */
	NSResponder *firstResponder = [[self window] firstResponder];
	if (![firstResponder isKindOfClass:[NSView class]] ||
		![(NSView *)firstResponder isDescendantOf:self] || 
		![[self window] isKeyWindow]) 
	{
		alternateSelectedControlColor = [[alternateSelectedControlColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace]
										 colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		lighterColor = [[lighterColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace]
						colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		darkerColor = [[darkerColor	colorUsingColorSpaceName:NSDeviceWhiteColorSpace]
						colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	}
	
	// Set up the helper function for drawing washes
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_twoColorsType *twoColors = malloc(sizeof(_twoColorsType)); 
	/* We malloc() the helper data because we may draw this wash during
	printing, in which case it won't necessarily be evaluated
	immediately. We need for all the data the shading function needs
	to draw to potentially outlive us. */
	[lighterColor getRed:&twoColors->red1 
				   green:&twoColors->green1
					blue:&twoColors->blue1 
				   alpha:&twoColors->alpha1];
	[darkerColor getRed:&twoColors->red2 
				  green:&twoColors->green2
				   blue:&twoColors->blue2 
				  alpha:&twoColors->alpha2];
	static const CGFloat domainAndRange[8] = {0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0};
	CGFunctionRef linearBlendFunctionRef = CGFunctionCreate(twoColors, 1, domainAndRange, 4, domainAndRange, &linearFunctionCallbacks);
	
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSUInteger rowIndex = [selectedRowIndexes indexGreaterThanOrEqualToIndex:0];
	
	while (rowIndex != NSNotFound) 
	{
		NSUInteger endOfCurrentRunRowIndex, newRowIndex = rowIndex;
		do 
		{
			endOfCurrentRunRowIndex = newRowIndex;
			newRowIndex = [selectedRowIndexes
						   indexGreaterThanIndex:endOfCurrentRunRowIndex];
		} while (newRowIndex == endOfCurrentRunRowIndex + 1);
		
		NSRect rowRect = NSUnionRect([self rectOfRow:rowIndex],
									 [self rectOfRow:endOfCurrentRunRowIndex]);
		
		NSRect topBar, washRect;
		NSDivideRect(rowRect, &topBar, &washRect, 1.0, NSMinYEdge);
		
		// Draw the top line of pixels of the selected row in the alternateSelectedControlColor
		[alternateSelectedControlColor set];
		NSRectFill(topBar);
		
		// Draw a soft wash underneath it
		CGContextRef context = [[NSGraphicsContext currentContext]
								graphicsPort];
		CGContextSaveGState(context); {
			CGContextClipToRect(context, (CGRect){{NSMinX(washRect),
			NSMinY(washRect)}, {NSWidth(washRect),
			NSHeight(washRect)}});
			CGShadingRef cgShading = CGShadingCreateAxial(colorSpace,
														  CGPointMake(0, NSMinY(washRect)), CGPointMake(0,
																										NSMaxY(washRect)), linearBlendFunctionRef, NO, NO);
			CGContextDrawShading(context, cgShading);
			CGShadingRelease(cgShading);
		} CGContextRestoreGState(context);
		
		rowIndex = newRowIndex;
	}
	
	
	CGFunctionRelease(linearBlendFunctionRef);
	CGColorSpaceRelease(colorSpace);
}

#if MAC_OS_X_VERSION_10_6
- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend
{
	[super selectRowIndexes:indexes byExtendingSelection:extend];
	[self setNeedsDisplay:YES]; /* we display extra because we draw
	multiple contiguous selected rows differently, so changing
	one row's selection can change how others draw.*/
}
#else
- (void)selectRow:(NSInteger)row byExtendingSelection:(BOOL)extend;
{
	[super selectRow:row byExtendingSelection:extend];
	[self setNeedsDisplay:YES]; /* we display extra because we draw
	multiple contiguous selected rows differently, so changing
	one row's selection can change how others draw.*/
}
#endif

- (void)deselectRow:(NSInteger)row;
	{
	[super deselectRow:row];
	[self setNeedsDisplay:YES]; /* we display extra because we draw
	multiple contiguous selected rows differently, so changing
	one row's selection can change how others draw.*/
}

// NSTableView (Private)

- (id)_highlightColorForCell:(NSCell *)cell;
{
	return nil;
}

- (void)_windowDidChangeKeyNotification:(NSNotification
										 *)notification;
{
	[self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ([theEvent type] == NSKeyDown)
	{
		//NSLog(@"Keypress: %@, %d, %d", [theEvent characters], [[theEvent characters] length], [[theEvent characters] characterAtIndex:0]);
		if ([[theEvent characters] compare:@" "] == NSOrderedSame)
		{
			if ([self.delegate respondsToSelector:@selector(tableViewDidReceiveSpaceKey:)])
				[(id<TPGradientTableViewDelegate>)self.delegate tableViewDidReceiveSpaceKey:self];
			return;
		}
		if ([[theEvent characters] compare:@"\x7f"] == NSOrderedSame)
		{
			if ([self.delegate respondsToSelector:@selector(tableViewDidReceiveDeleteKey:)])
				[(id<TPGradientTableViewDelegate>)self.delegate tableViewDidReceiveDeleteKey:self];
			return;
		}
	}
	[super keyDown:theEvent];
}

