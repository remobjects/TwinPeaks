//
//  ColoredTextView.h
//  DASchemaModeler
//
//  Created by Alexander Karpenko on 3/10/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPSyntaxColouring.h"



@interface TPSyntaxTextView : NSTextView
{
	NSInteger lineHeight;
	NSPoint startPoint;
    NSPoint startOrigin;
	CGFloat pageGuideX;
	NSColor *pageGuideColour;
	
	BOOL showPageGuide;
	
	NSCursor *colouredIBeamCursor;
	
	BOOL inCompleteMethod;
	TPSyntaxColouring *syntaxColouring;
	enum SyntaxDefinition syntaxDefinition;
	BOOL suggestAutocomplete;
}

@property (assign) NSCursor *colouredIBeamCursor;
@property (assign) BOOL inCompleteMethod;
@property (assign) BOOL suggestAutocomplete;

- (void)setDefaults;
- (NSInteger)lineHeight;
- (void)setTabWidth;
- (void)setPageGuideValues;
- (void)updateIBeamCursor;
- (void)recolor;

- (void) setSyntaxDefinition:(enum SyntaxDefinition)value;
- (enum SyntaxDefinition) syntaxDefinition;
@end
