//
//  TPTextView.m
//  DASchemaModeler
//
//  Created by Alexander Karpenko on 3/10/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import "TPSyntaxTextViewDefaults.h"
#import "TPSyntaxTextView.h"

@implementation TPSyntaxTextView

- (void) dealloc
{
	[syntaxColouring release];
	[super dealloc];
}

- (void)awakeFromNib
{
	//syntaxColouring = [[TPSyntaxColouring alloc] initWithOwner:self andSyntaxDefinition:sdDefault];
	
	_suggestAutocomplete = SUGGEST_AUTOCOMPLETE;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(viewBoundsDidChange:) 
												 name:NSViewBoundsDidChangeNotification 
											   object:[[self enclosingScrollView] contentView]];
	[self setDefaults];			
}


-(void)setString:(NSString *)string
{
	if (!string) 
		string = @"";
	
	if (!([string compare:[self string]] == NSOrderedSame)) {
		[super setString:string];
		[self didChangeText];
	}
}

-(void)viewBoundsDidChange:(NSNotification *)notification
{
	if (notification != nil && 
		[notification object] != nil && 
		[[notification object] isKindOfClass:[NSClipView class]] &&
		syntaxColouring != nil
	) 
		[syntaxColouring pageRecolourTextView:self];
}


- (void)setDefaults
{
	_inCompleteMethod = NO;
	
	[self setTabWidth];
	
	[self setVerticallyResizable:YES];
	[self setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	[self setAutoresizingMask:NSViewWidthSizable];
	[self setAllowsUndo:YES];
	[self setUsesFindPanel:YES];
	[self setAllowsDocumentBackgroundColorChange:NO];
	[self setRichText:NO];
	[self setImportsGraphics:NO];
	[self setUsesFontPanel:NO];
	
	[self setContinuousSpellCheckingEnabled:SPELL_CHECKING];
	[self setGrammarCheckingEnabled:GRAMMAR_CHECKING];
	
	[self setSmartInsertDeleteEnabled:YES];
	[self setAutomaticLinkDetectionEnabled:YES];
	[self setAutomaticQuoteSubstitutionEnabled:NO];
	
	[self setFont:DEFAULT_FONT];
	[self setTextColor:DEFAULT_TEXT_COLOUR];
	[self setInsertionPointColor:DEFAULT_TEXT_COLOUR];
	[self setBackgroundColor:DEFAULT_BACKGROUND_COLOUR];
	
	
	//[self setAutomaticDataDetectionEnabled:YES];
	//[self setAutomaticTextReplacementEnabled:YES];
	
	[self setPageGuideValues];
	
	[self updateIBeamCursor];	
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame] 
																options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveWhenFirstResponder) 
																  owner:self 
															   userInfo:nil];
	[self addTrackingArea:trackingArea];
	
	lineHeight = [[[self textContainer] layoutManager] defaultLineHeightForFont:DEFAULT_FONT];
}


- (void)insertNewline:(id)sender
{
	[super insertNewline:sender];
	
	// If we should indent automatically, check the previous line and scan all the whitespace at the beginning of the line into a string and insert that string into the new line
	NSString *lastLineString = [[self string] substringWithRange:[[self string] lineRangeForRange:NSMakeRange([self selectedRange].location - 1, 0)]];
	
	//IndentNewLinesAutomatically
	if (AUTOINDENT_NEW_LINES)
	{
		NSString *previousLineWhitespaceString;
		NSScanner *previousLineScanner = [[NSScanner alloc] initWithString:[[self string] substringWithRange:[[self string] lineRangeForRange:NSMakeRange([self selectedRange].location - 1, 0)]]];
		[previousLineScanner setCharactersToBeSkipped:nil];		
		if ([previousLineScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&previousLineWhitespaceString]) 
			[self insertText:previousLineWhitespaceString];
		[previousLineScanner release];
	}
	
	//AutomaticallyIndentBraces
	if (AUTOINDENT_BRACES) 
	{
		NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		NSInteger index = [lastLineString length];
		while (index--) {
			if ([characterSet characterIsMember:[lastLineString characterAtIndex:index]]) {
				continue;
			}
			if ([lastLineString characterAtIndex:index] == '{') {
				[self insertTab:nil];
			}
			break;
		}
	}
	
}


- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity
{
	if (granularity != NSSelectByWord || 
		[[self string] length] == proposedSelRange.location || 
		[[NSApp currentEvent] clickCount] != 2) 
	{ // If it's not a double-click return unchanged
		return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
	}
	
	NSInteger location = [super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByCharacter].location;
	NSInteger originalLocation = location;
	
	NSString *completeString = [self string];
	unichar characterToCheck = [completeString characterAtIndex:location];
	NSInteger skipMatchingBrace = 0;
	NSInteger lengthOfString = [completeString length];
	if (lengthOfString == proposedSelRange.location) 
	{ 
		// To avoid crash if a double-click occurs after any text
		return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
	}
	
	BOOL triedToMatchBrace = NO;
	
	if (characterToCheck == ')') 
	{
		triedToMatchBrace = YES;
		while (location--) 
		{
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '(') 
			{
				if (!skipMatchingBrace) 
					return NSMakeRange(location, originalLocation - location + 1);
				else 
					skipMatchingBrace--;
			} 
			else if (characterToCheck == ')') 
				skipMatchingBrace++;
			
		}
		NSBeep();
	} 
	else if (characterToCheck == '}') 
	{
		triedToMatchBrace = YES;
		while (location--) 
		{
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '{') 
			{
				if (!skipMatchingBrace) 
					return NSMakeRange(location, originalLocation - location + 1);
				else 
					skipMatchingBrace--;

			} 
			else if (characterToCheck == '}') 
				skipMatchingBrace++;
			
		}
		NSBeep();
	} else if (characterToCheck == ']') {
		triedToMatchBrace = YES;
		while (location--) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '[') {
				if (!skipMatchingBrace) {
					return NSMakeRange(location, originalLocation - location + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ']') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '>') {
		triedToMatchBrace = YES;
		while (location--) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '<') {
				if (!skipMatchingBrace) {
					return NSMakeRange(location, originalLocation - location + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '>') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '(') {
		triedToMatchBrace = YES;
		while (++location < lengthOfString) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == ')') {
				if (!skipMatchingBrace) {
					return NSMakeRange(originalLocation, location - originalLocation + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '(') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '{') {
		triedToMatchBrace = YES;
		while (++location < lengthOfString) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '}') {
				if (!skipMatchingBrace) {
					return NSMakeRange(originalLocation, location - originalLocation + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '{') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '[') {
		triedToMatchBrace = YES;
		while (++location < lengthOfString) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == ']') {
				if (!skipMatchingBrace) {
					return NSMakeRange(originalLocation, location - originalLocation + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '[') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '<') {
		triedToMatchBrace = YES;
		while (++location < lengthOfString) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '>') {
				if (!skipMatchingBrace) {
					return NSMakeRange(originalLocation, location - originalLocation + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '<') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	}
	
	// If it has a found a "starting" brace but not found a match, a double-click should only select the "starting" brace and not what it usually would select at a double-click
	if (triedToMatchBrace) {
		return [super selectionRangeForProposedRange:NSMakeRange(proposedSelRange.location, 1) granularity:NSSelectByCharacter];
	} else {
		
		NSInteger startLocation = originalLocation;
		NSInteger stopLocation = originalLocation;
		NSInteger minLocation = [super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByWord].location;
		NSInteger maxLocation = NSMaxRange([super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByWord]);
		
		BOOL hasFoundSomething = NO;
		while (--startLocation >= minLocation) {
			if ([completeString characterAtIndex:startLocation] == '.' || [completeString characterAtIndex:startLocation] == ':') {
				hasFoundSomething = YES;
				break;
			}
		}
		
		while (++stopLocation < maxLocation) {
			if ([completeString characterAtIndex:stopLocation] == '.' || [completeString characterAtIndex:stopLocation] == ':') {
				hasFoundSomething = YES;
				break;
			}
		}
		
		if (hasFoundSomething == YES) {
			return NSMakeRange(startLocation + 1, stopLocation - startLocation - 1);
		} else {
			return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
		}
	}
}

-(BOOL)isOpaque
{
	return YES;
}


- (void)insertTab:(id)sender
{	
	BOOL shouldShiftText = NO;
	
	if ([self selectedRange].length > 0) { // Check to see if the selection is in the text or if it's at the beginning of a line or in whitespace; if one doesn't do this one shifts the line if there's only one suggestion in the auto-complete
		NSRange rangeOfFirstLine = [[self string] lineRangeForRange:NSMakeRange([self selectedRange].location, 0)];
		NSInteger firstCharacterOfFirstLine = rangeOfFirstLine.location;
		while ([[self string] characterAtIndex:firstCharacterOfFirstLine] == ' ' || [[self string] characterAtIndex:firstCharacterOfFirstLine] == '\t') {
			firstCharacterOfFirstLine++;
		}
		if ([self selectedRange].location <= firstCharacterOfFirstLine) {
			shouldShiftText = YES;
		}
	}
	
	if (shouldShiftText) 
	{
		//???
	}
	else if (INDENT_WITH_SPACES) 
	{
		NSMutableString *spacesString = [NSMutableString string];
		NSInteger numberOfSpacesPerTab = TAB_WIDTH;
		if (USE_TAB_STOPS) 
		{
			NSInteger locationOnLine = [self selectedRange].location - [[self string] lineRangeForRange:[self selectedRange]].location;
			NSInteger numberOfSpacesLess = locationOnLine % numberOfSpacesPerTab;
			numberOfSpacesPerTab = numberOfSpacesPerTab - numberOfSpacesLess;
		}
		while (numberOfSpacesPerTab--) 
			[spacesString appendString:@" "];
		
		[self insertText:spacesString];
	}
	
	// If there's only one word matching in auto-complete there's no list but just the rest of the word inserted and selected; and if you do a normal tab then the text is removed so this will put the cursor at the end of that word
	else if ([self selectedRange].length > 0) 
		[self setSelectedRange:NSMakeRange(NSMaxRange([self selectedRange]), 0)];
	else 
		[super insertTab:sender];
	
}


- (void)mouseDown:(NSEvent *)theEvent
{
	if (([theEvent modifierFlags] & NSAlternateKeyMask) && ([theEvent modifierFlags] & NSCommandKeyMask)) 
	{ 
		// If the option and command keys are pressed, change the cursor to grab-cursor
		startPoint = [theEvent locationInWindow];
		startOrigin = [[[self enclosingScrollView] contentView] documentVisibleRect].origin;
		[[self enclosingScrollView] setDocumentCursor:[NSCursor openHandCursor]];
	} 
	else 
	{
		[super mouseDown:theEvent];
	}
}


- (void)mouseDragged:(NSEvent *)theEvent
{
    if ([[NSCursor currentCursor] isEqual:[NSCursor openHandCursor]]) {
		[self scrollPoint:NSMakePoint(startOrigin.x - ([theEvent locationInWindow].x - startPoint.x) * 3, startOrigin.y + ([theEvent locationInWindow].y - startPoint.y) * 3)];
	} else {
		[super mouseDragged:theEvent];
	}
}


- (void)mouseUp:(NSEvent *)theEvent
{
	[[self enclosingScrollView] setDocumentCursor:[NSCursor IBeamCursor]];
}


- (NSInteger)lineHeight
{
    return lineHeight;
}


- (void)setTabWidth
{
	// Set the width of every tab by first checking the size of the tab in spaces in the current font and then remove all tabs that sets automatically and then set the default tab stop distance
	NSMutableString *sizeString = [NSMutableString string];
	NSInteger numberOfSpaces = TAB_WIDTH;
	while (numberOfSpaces--) 
		[sizeString appendString:@" "];
	
	NSDictionary *sizeAttribute = [[NSDictionary alloc] initWithObjectsAndKeys:DEFAULT_FONT, NSFontAttributeName, nil];
	CGFloat sizeOfTab = [sizeString sizeWithAttributes:sizeAttribute].width;
	
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	
	NSArray *array = [style tabStops];
	for (id item in array) 
		[style removeTabStop:item];
	
	[style setDefaultTabInterval:sizeOfTab];
	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
	[self setTypingAttributes:attributes];
}


- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if (showPageGuide == YES) {
		NSRect bounds = [self bounds]; 
		if ([self needsToDrawRect:NSMakeRect(pageGuideX, 0, 1, bounds.size.height)] == YES) 
		{ 
			// So that it doesn't draw the line if only e.g. the cursor updates
			[pageGuideColour set];
			[NSBezierPath strokeRect:NSMakeRect(pageGuideX, 0, 0, bounds.size.height)];
		}
	}
}


- (void)setPageGuideValues
{
	NSDictionary *sizeAttribute = [[NSDictionary alloc] initWithObjectsAndKeys:DEFAULT_FONT, NSFontAttributeName, nil];
	NSString *sizeString = @" ";
	CGFloat sizeOfCharacter = [sizeString sizeWithAttributes:sizeAttribute].width;
	[sizeAttribute release];
	pageGuideX = (sizeOfCharacter * (1 + 1)) - 1.5; // -1.5 to put it between the two characters and draw only on one pixel and not two (as the system draws it in a special way), and that's also why the width above is set to zero 
	
	NSColor *color = DEFAULT_TEXT_COLOUR;
	pageGuideColour = [color colorWithAlphaComponent:([color alphaComponent] / 4)]; // Use the same colour as the text but with more transparency
	
	showPageGuide = NO;//??
	
	[self display]; // To reflect the new values in the view
}


- (void)insertText:(NSString *)aString
{
	if ([aString isEqualToString:@"}"] && AUTOINDENT_NEW_LINES && AUTOINDENT_BRACES) 
	{
		unichar characterToCheck;
		NSInteger location = [self selectedRange].location;
		NSString *completeString = [self string];
		NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
		NSRange currentLineRange = [completeString lineRangeForRange:NSMakeRange([self selectedRange].location, 0)];
		NSInteger lineLocation = location;
		NSInteger lineStart = currentLineRange.location;
		while (--lineLocation >= lineStart) { // If there are any characters before } on the line skip indenting
			if ([whitespaceCharacterSet characterIsMember:[completeString characterAtIndex:lineLocation]]) {
				continue;
			}
			[super insertText:aString];
			return;
		}
		
		BOOL hasInsertedBrace = NO;
		NSUInteger skipMatchingBrace = 0;
		while (location--) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '{') 
			{
				if (skipMatchingBrace == 0) 
				{ 
					// If we have found the opening brace check first how much space is in front of that line so the same amount can be inserted in front of the new line
					NSString *openingBraceLineWhitespaceString;
					NSScanner *openingLineScanner = [[NSScanner alloc] initWithString:[completeString substringWithRange:[completeString lineRangeForRange:NSMakeRange(location, 0)]]];
					[openingLineScanner setCharactersToBeSkipped:nil];
					BOOL foundOpeningBraceWhitespace = [openingLineScanner scanCharactersFromSet:whitespaceCharacterSet intoString:&openingBraceLineWhitespaceString];
					
					if (foundOpeningBraceWhitespace == YES) 
					{
						NSMutableString *newLineString = [NSMutableString stringWithString:openingBraceLineWhitespaceString];
						[newLineString appendString:@"}"];
						[newLineString appendString:[completeString substringWithRange:NSMakeRange([self selectedRange].location, NSMaxRange(currentLineRange) - [self selectedRange].location)]];
						if ([self shouldChangeTextInRange:currentLineRange replacementString:newLineString]) 
						{
							[self replaceCharactersInRange:currentLineRange withString:newLineString];
							[self didChangeText];
						}
						hasInsertedBrace = YES;
						[self setSelectedRange:NSMakeRange(currentLineRange.location + [openingBraceLineWhitespaceString length] + 1, 0)]; // +1 because we have inserted a character
					} 
					else 
					{
						NSString *restOfLineString = [completeString substringWithRange:NSMakeRange([self selectedRange].location, NSMaxRange(currentLineRange) - [self selectedRange].location)];
						if ([restOfLineString length] != 0) 
						{ 
							// To fix a bug where text after the } can be deleted
							NSMutableString *replaceString = [NSMutableString stringWithString:@"}"];
							[replaceString appendString:restOfLineString];
							hasInsertedBrace = YES;
							NSInteger lengthOfWhiteSpace = 0;
							if (foundOpeningBraceWhitespace == YES) {
								lengthOfWhiteSpace = [openingBraceLineWhitespaceString length];
							}
							if ([self shouldChangeTextInRange:currentLineRange replacementString:replaceString]) 
							{
								[self replaceCharactersInRange:[completeString lineRangeForRange:currentLineRange] withString:replaceString];
								[self didChangeText];
							}
							[self setSelectedRange:NSMakeRange(currentLineRange.location + lengthOfWhiteSpace + 1, 0)]; // +1 because we have inserted a character
						} 
						else 
						{
							[self replaceCharactersInRange:[completeString lineRangeForRange:currentLineRange] withString:@""]; // Remove whitespace before }
						}
						
					}
					[openingLineScanner release];
					break;
				} else 
				{
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '}') 
			{
				skipMatchingBrace++;
			}
		}
		if (hasInsertedBrace == NO) 
		{
			[super insertText:aString];
		}
	} 
	else if ([aString isEqualToString:@"("] && AUTOINSERT_CLOSING_PATERNTHESIS) 
	{
		[super insertText:aString];
		NSRange selectedRange = [self selectedRange];
		if ([self shouldChangeTextInRange:selectedRange replacementString:@")"]) 
		{
			[self replaceCharactersInRange:selectedRange withString:@")"];
			[self didChangeText];
			[self setSelectedRange:NSMakeRange(selectedRange.location - 0, 0)];
		}
	} 
	else if (AUTOINSERT_CLOSING_BRACES && [aString isEqualToString:@"{"]) 
	{
		[super insertText:aString];
		NSRange selectedRange = [self selectedRange];
		if ([self shouldChangeTextInRange:selectedRange replacementString:@"}"]) 
		{
			[self replaceCharactersInRange:selectedRange withString:@"}"];
			[self didChangeText];
			[self setSelectedRange:NSMakeRange(selectedRange.location - 0, 0)];
		}
	} 
	else 
	{
		[super insertText:aString];
	}
}

- (void)updateIBeamCursor
{
	NSColor *textColour = [DEFAULT_TEXT_COLOUR colorUsingColorSpaceName:NSCalibratedWhiteColorSpace];
	
	if (textColour != nil && [textColour whiteComponent] == 0.0 && [textColour alphaComponent] == 1.0) 
	{ 
		// Keep the original cursor if it's black
		[self setColouredIBeamCursor:[NSCursor IBeamCursor]];
	} 
	else 
	{
		NSImage *cursorImage = [[NSCursor IBeamCursor] image];
		[cursorImage lockFocus];
		[DEFAULT_TEXT_COLOUR set];
		NSRectFillUsingOperation(NSMakeRect(0, 0, [cursorImage size].width, [cursorImage size].height), NSCompositeSourceAtop);
		[cursorImage unlockFocus];
		[self setColouredIBeamCursor:[[NSCursor alloc] initWithImage:cursorImage hotSpot:[[NSCursor IBeamCursor] hotSpot]]];
	}
}


- (void)cursorUpdate:(NSEvent *)event
{
	[_colouredIBeamCursor set];
}


- (void)mouseMoved:(NSEvent *)theEvent
{
	if ([NSCursor currentCursor] == [NSCursor IBeamCursor]) 
	{
		[_colouredIBeamCursor set];
	}
}


- (void)performFindPanelAction:(id)sender
{
	[super performFindPanelAction:sender];
}

- (void)recolor
{
	[syntaxColouring pageRecolour];
}

- (void) setSyntaxDefinition:(enum SyntaxDefinition)value
{
	if (syntaxDefinition == value) return;
	TPSyntaxColouring *newSyntaxColouring = [[[TPSyntaxColouring alloc] initWithOwner:self andSyntaxDefinition:value] retain];
	[syntaxColouring release];
	syntaxColouring = newSyntaxColouring;
	[syntaxColouring pageRecolour];
}

- (enum SyntaxDefinition) syntaxDefinition
{
	return syntaxDefinition;
}


@end
