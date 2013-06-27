//
//  SyntaxColouring.h
//  ColoredTextView
//
//  Created by Alexander Karpenko on 3/10/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TPSyntaxTextView;
@class ICUPattern;
@class ICUMatcher;

enum SyntaxDefinition
{
	sdDefault,
	sdSql,
	sdXml,
	sdHtml,
	sdJs,
	sdObjc,
	sdPas,
	sdOxygene,
	sdHydrogene,
	sdDASql
};

@interface TPSyntaxColouring : NSObject 
#if MAC_OS_X_VERSION_10_6
<NSTextStorageDelegate, NSTextViewDelegate> 
#endif
{
	
	NSUndoManager *undoManager;
	NSLayoutManager *customLayoutManager;
	
	NSTimer *autocompleteWordsTimer;
	NSInteger currentYOfSelectedCharacter, lastYOfSelectedCharacter, currentYOfLastCharacterInLine, lastYOfLastCharacterInLine, currentYOfLastCharacter, lastYOfLastCharacter, lastCursorLocation;
	
	NSCharacterSet *letterCharacterSet, *keywordStartCharacterSet, *keywordEndCharacterSet;
	NSCharacterSet *attributesCharacterSet;

	
	NSDictionary *commandsColour, *commentsColour, *instructionsColour, *keywordsColour, *autocompleteWordsColour, *stringsColour, *variablesColour, *attributesColour, *lineHighlightColour;
	
	NSEnumerator *wordEnumerator;
	NSSet *keywords;
	NSSet *autocompleteWords;
	NSArray *keywordsAndAutocompleteWords;
	BOOL keywordsCaseSensitive;
	BOOL recolourKeywordIfAlreadyColoured;
	NSString *beginCommand;
	NSString *endCommand;
	NSString *beginInstruction;
	NSString *endInstruction;
	NSCharacterSet *beginVariable;
	NSCharacterSet *endVariable;
	NSString *firstString;
	unichar firstStringUnichar;
	NSString *secondString;
	unichar secondStringUnichar;
	NSString *firstSingleLineComment, *secondSingleLineComment, *beginFirstMultiLineComment, *endFirstMultiLineComment, *beginSecondMultiLineComment, *endSecondMultiLineComment, *functionDefinition, *removeFromFunction;
	
	NSString *completeString;
	NSString *searchString;
	NSScanner *scanner;
	NSScanner *completeDocumentScanner;	
	NSInteger beginning, end, endOfLine, index, length, searchStringLength, commandLocation, skipEndCommand, beginLocationInMultiLine, endLocationInMultiLine, searchSyntaxLength, rangeLocation;
	NSRange rangeOfLine;
	NSString *keyword;
	BOOL shouldOnlyColourTillTheEndOfLine;
	unichar commandCharacterTest;
	unichar beginCommandCharacter;
	unichar endCommandCharacter;
	BOOL shouldColourMultiLineStrings;
	BOOL foundMatch;
	NSInteger completeStringLength;
	unichar characterToCheck;
	NSRange editedRange;
	NSInteger cursorLocation;
	NSInteger differenceBetweenLastAndPresent;
	NSInteger skipMatchingBrace;
	NSRect visibleRect;
	NSRange visibleRange;
	NSInteger beginningOfFirstVisibleLine;
	NSInteger endOfLastVisibleLine;
	NSRange selectedRange;;
	NSInteger stringLength;
	NSString *keywordTestString;
	NSString *autocompleteTestString;
	NSRange searchRange;
	NSInteger maxRange;
	NSTextContainer *textContainer;
	BOOL reactToChanges;
	
	
	ICUPattern *firstStringPattern;
	ICUPattern *secondStringPattern;
	
	ICUMatcher *firstStringMatcher;
	ICUMatcher *secondStringMatcher;
	
	NSRange foundRange;
	NSTimer *liveUpdatePreviewTimer;
	NSRange lastLineHighlightRange;
	TPSyntaxTextView *owner;
}

@property BOOL reactToChanges;

@property (copy) NSString *functionDefinition;
@property (copy) NSString *removeFromFunction;

@property (readonly) NSUndoManager *undoManager;

- (id)initWithOwner:(TPSyntaxTextView *)textView andSyntaxDefinition:(enum SyntaxDefinition)syntaxDef;
- (void)setSyntaxDefinition:(enum SyntaxDefinition)syntaxDefinition;


@end

@interface TPSyntaxColouring (Private)

- (void)prepareRegularExpressions;
- (void)recolourRange:(NSRange)range;

- (void)removeAllColours;
- (void)removeColoursFromRange:(NSRange)range;

- (void)pageRecolour;
- (void)pageRecolourTextView:(TPSyntaxTextView *)textView;

- (void)setColour:(NSDictionary *)colour range:(NSRange)range;
- (void)highlightLineRange:(NSRange)lineRange;

@end
