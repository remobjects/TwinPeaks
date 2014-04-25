//
//  SyntaxColouring.m
//  ColoredTextView
//
//  Created by Alexander Karpenko on 3/10/10.
//  Copyright 2010 RemObjects Software. All rights reserved.
//

#import "TPSyntaxColouring.h"
#import "TPSyntaxTextView.h"
#import "TPSyntaxTextViewDefaults.h"

#import "ICUPattern.h"
#import "ICUMatcher.h"
#import "NSStringICUAdditions.h"

@implementation TPSyntaxColouring

@synthesize reactToChanges = reactToChanges;
@synthesize functionDefinition = functionDefinition;
@synthesize removeFromFunction = removeFromFunction;
@synthesize undoManager = undoManager;

- (void) dealloc
{
	[undoManager release];
	
	[commandsColour release];
	[commentsColour release];
	[instructionsColour release];
	[keywordsColour release];
	[autocompleteWordsColour release];
	[stringsColour release];
	[variablesColour release];
	[attributesColour release];
	[lineHighlightColour release];
	
	[letterCharacterSet release];
	[keywordStartCharacterSet release];
	[keywordEndCharacterSet release];
	[keywords release];

	[super dealloc];
}


- (id)init
{
	NSLog(@"SyntaxColouring happened");
	
	[self initWithOwner:nil andSyntaxDefinition:sdSql];
	return self;
}


- (id)initWithOwner:(TPSyntaxTextView *)textView andSyntaxDefinition:(enum SyntaxDefinition)syntaxDef
{
	if (self = [super init]) 
	{
		owner = textView;
		customLayoutManager = [owner layoutManager];

		// set colours
		commandsColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_COMMANDS, NSForegroundColorAttributeName, nil];
		commentsColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_COMMENTS, NSForegroundColorAttributeName, nil];
		instructionsColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_INSTRUCTIONS, NSForegroundColorAttributeName, nil];
		keywordsColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_KEYWORDS, NSForegroundColorAttributeName, nil];
		autocompleteWordsColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_AUTOCOMPLETE, NSForegroundColorAttributeName, nil];
		stringsColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_STRINGS, NSForegroundColorAttributeName, nil];
		variablesColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_VARIABLES, NSForegroundColorAttributeName, nil];
		attributesColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_ATTRIBUTES, NSForegroundColorAttributeName, nil];
		lineHighlightColour = [[NSDictionary alloc] initWithObjectsAndKeys:COLOUR_HIGHLIGHTED_LINE, NSBackgroundColorAttributeName, nil];
		
		letterCharacterSet = [NSCharacterSet letterCharacterSet];
		NSMutableCharacterSet *temporaryCharacterSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
		[temporaryCharacterSet addCharactersInString:@"_:@#"];
		keywordStartCharacterSet = [temporaryCharacterSet copy];
		[temporaryCharacterSet release];
		
		temporaryCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
		[temporaryCharacterSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
		[temporaryCharacterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
		[temporaryCharacterSet removeCharactersInString:@"_"];
		keywordEndCharacterSet = [temporaryCharacterSet copy];
		[temporaryCharacterSet release];
		
		temporaryCharacterSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
		[temporaryCharacterSet addCharactersInString:@" -"]; // If there are two spaces before an attribute
		attributesCharacterSet = [temporaryCharacterSet copy];
		[temporaryCharacterSet release];
		
		[self setSyntaxDefinition:syntaxDef];
		
		completeString = [owner string];
		textContainer = [owner textContainer];
		
		reactToChanges = YES;
		
		[owner setDelegate:self];
		[[owner textStorage] setDelegate:self];
		undoManager = [[NSUndoManager alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfCanUndo) name:@"NSUndoManagerDidUndoChangeNotification" object:undoManager];
		
		lastLineHighlightRange = NSMakeRange(0, 0);		
	}
    return self;
}


- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView
{
	return undoManager;
}

#pragma mark -
#pragma mark Setup

- (void)setSyntaxDefinition:(enum SyntaxDefinition)syntaxDefinition
{	
	NSString *fileToUse;
	switch (syntaxDefinition) 
	{
		case sdSql:		
			fileToUse = @"sql";			
			break;
		case sdXml:		
			fileToUse = @"xml";			
			break;
		case sdHtml:
			fileToUse = @"html";
			break;
		case sdJs:
			fileToUse = @"javascript";	
			break;
		case sdObjc:	
			fileToUse = @"objectivec";	
			break;
		case sdPas:
			fileToUse = @"pascal";
			break;
		case sdOxygene:
			fileToUse = @"oxygene";
			break;
		case sdHydrogene:
			fileToUse = @"hydrogene";
			break;
		case sdDASql:
			fileToUse = @"dasql";
			break;
			
		default:		
			fileToUse = @"default";		
			break;
	}
	
	
	NSDictionary *syntaxDictionary;
	//syntaxDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileToUse ofType:@"plist" inDirectory:@"Syntax Definitions"]];
	syntaxDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[TPSyntaxTextView class]] pathForResource:fileToUse ofType:@"plist"]];
	
	if (!syntaxDictionary) 
		syntaxDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Standard", @"standard", [NSString string], nil] forKeys:[NSArray arrayWithObjects:@"name", @"file", @"extensions", nil]]; // If it can't find a syntax file use Standard
	
	NSMutableArray *keywordsAndAutocompleteWordsTemporary = [NSMutableArray array];
	
    NSSet *kws;
    
	// If the plist file is malformed be sure to set the values to something
    NSArray *arr = [syntaxDictionary valueForKey:@"keywords"];
	if (arr != nil) {
        kws = [NSSet setWithArray:arr];
		[keywordsAndAutocompleteWordsTemporary addObjectsFromArray:arr];
	}
	
    arr = [syntaxDictionary valueForKey:@"autocompleteWords"];
	if (arr != nil) {
		autocompleteWords = [NSSet setWithArray:arr];
		[keywordsAndAutocompleteWordsTemporary addObjectsFromArray:arr];
	}
	
	if (COLOUR_AUTOCOMPLETE_AS_KEYWORDS) 
		kws = [NSSet setWithArray:keywordsAndAutocompleteWordsTemporary];
	
	keywordsAndAutocompleteWords = [keywordsAndAutocompleteWordsTemporary sortedArrayUsingSelector:@selector(compare:)];
	[keywordsAndAutocompleteWords retain];
	
	if ([syntaxDictionary valueForKey:@"recolourKeywordIfAlreadyColoured"]) {
		recolourKeywordIfAlreadyColoured = [[syntaxDictionary valueForKey:@"recolourKeywordIfAlreadyColoured"] boolValue];
	}
	
	if ([syntaxDictionary valueForKey:@"keywordsCaseSensitive"]) {
		keywordsCaseSensitive = [[syntaxDictionary valueForKey:@"keywordsCaseSensitive"] boolValue];
	}
	
	if (keywordsCaseSensitive == NO) 
	{
		NSMutableArray *lowerCaseKeywords = [[NSMutableArray alloc] init];
		for (id item in kws) {
			[lowerCaseKeywords addObject:[item lowercaseString]];
		}
		kws = [[NSSet alloc] initWithArray:lowerCaseKeywords];
		[lowerCaseKeywords release];
	}
    
    [keywords release];
    keywords = [kws retain];
	
	if ([syntaxDictionary valueForKey:@"beginCommand"]) {
		beginCommand = [syntaxDictionary valueForKey:@"beginCommand"];
	} else { 
		beginCommand = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"endCommand"]) {
		endCommand = [syntaxDictionary valueForKey:@"endCommand"];
	} else { 
		endCommand = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"beginInstruction"]) {
		beginInstruction = [syntaxDictionary valueForKey:@"beginInstruction"];
	} else {
        beginInstruction = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"endInstruction"]) {
		endInstruction = [syntaxDictionary valueForKey:@"endInstruction"];
	} else {
		endInstruction = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"beginVariable"]) {
		beginVariable = [NSCharacterSet characterSetWithCharactersInString:[syntaxDictionary valueForKey:@"beginVariable"]];
	}
	
	if ([syntaxDictionary valueForKey:@"endVariable"]) {
		endVariable = [NSCharacterSet characterSetWithCharactersInString:[syntaxDictionary valueForKey:@"endVariable"]];
	} else {
		endVariable = [NSCharacterSet characterSetWithCharactersInString:@""];
	}
	
	if ([syntaxDictionary valueForKey:@"firstString"]) {
		firstString = [syntaxDictionary valueForKey:@"firstString"];
		if (![[syntaxDictionary valueForKey:@"firstString"] isEqualToString:@""]) {
			firstStringUnichar = [[syntaxDictionary valueForKey:@"firstString"] characterAtIndex:0];
		}
	} else { 
		firstString = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"secondString"]) {
		secondString = [syntaxDictionary valueForKey:@"secondString"];
		if (![[syntaxDictionary valueForKey:@"secondString"] isEqualToString:@""]) {
			secondStringUnichar = [[syntaxDictionary valueForKey:@"secondString"] characterAtIndex:0];
		}
	} else { 
		secondString = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"firstSingleLineComment"]) {
		firstSingleLineComment = [syntaxDictionary valueForKey:@"firstSingleLineComment"];
	} else {
		firstSingleLineComment = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"secondSingleLineComment"]) {
		secondSingleLineComment = [syntaxDictionary valueForKey:@"secondSingleLineComment"];
	} else {
		secondSingleLineComment = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"beginFirstMultiLineComment"]) {
		beginFirstMultiLineComment = [syntaxDictionary valueForKey:@"beginFirstMultiLineComment"];
	} else {
		beginFirstMultiLineComment = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"endFirstMultiLineComment"]) {
		endFirstMultiLineComment = [syntaxDictionary valueForKey:@"endFirstMultiLineComment"];
	} else {
		endFirstMultiLineComment = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"beginSecondMultiLineComment"]) {
		beginSecondMultiLineComment = [syntaxDictionary valueForKey:@"beginSecondMultiLineComment"];
	} else {
		beginSecondMultiLineComment = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"endSecondMultiLineComment"]) {
		endSecondMultiLineComment = [syntaxDictionary valueForKey:@"endSecondMultiLineComment"];
	} else {
		endSecondMultiLineComment = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"functionDefinition"]) {
		self.functionDefinition = [syntaxDictionary valueForKey:@"functionDefinition"];
	} else {
		self.functionDefinition = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"removeFromFunction"]) {
		self.removeFromFunction = [syntaxDictionary valueForKey:@"removeFromFunction"];
	} else {
		self.removeFromFunction = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"excludeFromKeywordStartCharacterSet"]) {
		NSMutableCharacterSet *temporaryCharacterSet = [keywordStartCharacterSet mutableCopy];
		[temporaryCharacterSet removeCharactersInString:[syntaxDictionary valueForKey:@"excludeFromKeywordStartCharacterSet"]];
		keywordStartCharacterSet = [temporaryCharacterSet copy];
		[temporaryCharacterSet release];
	}
	
	if ([syntaxDictionary valueForKey:@"excludeFromKeywordEndCharacterSet"]) {
		NSMutableCharacterSet *temporaryCharacterSet = [keywordEndCharacterSet mutableCopy];
		[temporaryCharacterSet removeCharactersInString:[syntaxDictionary valueForKey:@"excludeFromKeywordEndCharacterSet"]];
		keywordEndCharacterSet = [temporaryCharacterSet copy];
		[temporaryCharacterSet release];
	}
	
	if ([syntaxDictionary valueForKey:@"includeInKeywordStartCharacterSet"]) {
		NSMutableCharacterSet *temporaryCharacterSet = [keywordStartCharacterSet mutableCopy];
		[temporaryCharacterSet addCharactersInString:[syntaxDictionary valueForKey:@"includeInKeywordStartCharacterSet"]];
		keywordStartCharacterSet = [temporaryCharacterSet copy];
		[temporaryCharacterSet release];
	}
	
	if ([syntaxDictionary valueForKey:@"includeInKeywordEndCharacterSet"]) {
		NSMutableCharacterSet *temporaryCharacterSet = [keywordEndCharacterSet mutableCopy];
		[temporaryCharacterSet addCharactersInString:[syntaxDictionary valueForKey:@"includeInKeywordEndCharacterSet"]];
		keywordEndCharacterSet = [temporaryCharacterSet copy];
		[temporaryCharacterSet release];
	}
	
	[self prepareRegularExpressions];
}


- (void)prepareRegularExpressions
{
	if (COLOUR_MULTILINE_STRINGS == NO) {
		firstStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\\\r\\n]*+(?:\\\\(?:.|$)[^%@\\\\\\r\\n]*+)*+%@", firstString, firstString, firstString, firstString]];
		
		secondStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\\\r\\n]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", secondString, secondString, secondString, secondString]];
		
	} else {
		firstStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", firstString, firstString, firstString, firstString]];
		
		secondStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", secondString, secondString, secondString, secondString]];
	}
}


#pragma mark -
#pragma mark Colouring

- (void)removeAllColours
{
	NSRange wholeRange = NSMakeRange(0, [completeString length]);
	[customLayoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:wholeRange];
}


- (void)removeColoursFromRange:(NSRange)range
{
	[customLayoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
}


- (void)pageRecolour
{
	[self pageRecolourTextView:owner];
}


- (void)pageRecolourTextView:(TPSyntaxTextView *)textView
{
	
	if (textView == nil)
		return;
	
	visibleRect = [[[textView enclosingScrollView] contentView] documentVisibleRect];
	visibleRange = [[textView layoutManager] glyphRangeForBoundingRect:visibleRect inTextContainer:[textView textContainer]];
	beginningOfFirstVisibleLine = [[textView string] lineRangeForRange:NSMakeRange(visibleRange.location, 0)].location;
	endOfLastVisibleLine = NSMaxRange([completeString lineRangeForRange:NSMakeRange(NSMaxRange(visibleRange), 0)]);
	
	[self recolourRange:NSMakeRange(beginningOfFirstVisibleLine, endOfLastVisibleLine - beginningOfFirstVisibleLine)];
}


- (void)recolourRange:(NSRange)range
{
	if (reactToChanges == NO) 
		return;
	
	shouldOnlyColourTillTheEndOfLine = COLOUR_TILL_END_OF_LINE;
	shouldColourMultiLineStrings = COLOUR_MULTILINE_STRINGS;
	
	NSRange effectiveRange = range;
	
	if (shouldColourMultiLineStrings) 
	{ 
		// When multiline strings are coloured it needs to go backwards to find where the string might have started if it's "above" the top of the screen
		NSInteger beginFirstStringInMultiLine = [completeString rangeOfString:firstString options:NSBackwardsSearch range:NSMakeRange(0, effectiveRange.location)].location;
		if (beginFirstStringInMultiLine != NSNotFound && 
			[[customLayoutManager temporaryAttributesAtCharacterIndex:beginFirstStringInMultiLine effectiveRange:NULL] isEqualToDictionary:stringsColour]) 
		{
			NSInteger startOfLine = [completeString lineRangeForRange:NSMakeRange(beginFirstStringInMultiLine, 0)].location;
			effectiveRange = NSMakeRange(startOfLine, range.length + (range.location - startOfLine));
		}
	}
	
	rangeLocation = effectiveRange.location;
	maxRange = NSMaxRange(effectiveRange);
	searchString = [completeString substringWithRange:effectiveRange];
	searchStringLength = [searchString length];
	if (searchStringLength == 0)
		return;
	
	scanner = [[NSScanner alloc] initWithString:searchString];
	[scanner autorelease];
	[scanner setCharactersToBeSkipped:nil];
	completeDocumentScanner = [[NSScanner alloc] initWithString:completeString];
	[completeDocumentScanner autorelease];
	[completeDocumentScanner setCharactersToBeSkipped:nil];
	
	completeStringLength = [completeString length];
	
	beginLocationInMultiLine = 0;
	
	[self removeColoursFromRange:range];		
	
	
	@try 
	{	
		
		// Commands
		if (DO_COLOUR_COMMANDS && ![beginCommand isEqualToString:@""]) 
		{
			searchSyntaxLength = [endCommand length];
			beginCommandCharacter = [beginCommand characterAtIndex:0];
			endCommandCharacter = [endCommand characterAtIndex:0];
			while (![scanner isAtEnd]) 
			{
				[scanner scanUpToString:beginCommand intoString:nil];
				beginning = [scanner scanLocation];
				endOfLine = NSMaxRange([searchString lineRangeForRange:NSMakeRange(beginning, 0)]);
				if (![scanner scanUpToString:endCommand intoString:nil] || [scanner scanLocation] >= endOfLine) 
				{
					[scanner setScanLocation:endOfLine];
					continue; // Don't colour it if it hasn't got a closing tag
				} 
				else 
				{
					// To avoid problems with strings like <yada <%=yada%> yada> we need to balance the number of begin- and end-tags
					// If ever there's a beginCommand or endCommand with more than one character then do a check first
					commandLocation = beginning + 1;
					skipEndCommand = 0;
					
					while (commandLocation < endOfLine) {
						commandCharacterTest = [searchString characterAtIndex:commandLocation];
						if (commandCharacterTest == endCommandCharacter) {
							if (!skipEndCommand) {
								break;
							} else {
								skipEndCommand--;
							}
						}
						if (commandCharacterTest == beginCommandCharacter) {
							skipEndCommand++;
						}
						commandLocation++;
					}
					if (commandLocation < endOfLine) {
						[scanner setScanLocation:commandLocation + searchSyntaxLength];
					} else {
						[scanner setScanLocation:endOfLine];
					}
				}
				
				[self setColour:commandsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
			}
		}
		
		
		// Instructions
		if (DO_COLOUR_INSTRUCTIONS && ![beginInstruction isEqualToString:@""]) {
			// It takes too long to scan the whole document if it's large, so for instructions, first multi-line comment and second multi-line comment search backwards and begin at the start of the first beginInstruction etc. that it finds from the present position and, below, break the loop if it has passed the scanned range (i.e. after the end instruction)
			
			beginLocationInMultiLine = [completeString rangeOfString:beginInstruction options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
			endLocationInMultiLine = [completeString rangeOfString:endInstruction options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
			if (beginLocationInMultiLine == NSNotFound || (endLocationInMultiLine != NSNotFound && beginLocationInMultiLine < endLocationInMultiLine)) {
				beginLocationInMultiLine = rangeLocation;
			}			
			
			searchSyntaxLength = [endInstruction length];
			while (![completeDocumentScanner isAtEnd]) {
				searchRange = NSMakeRange(beginLocationInMultiLine, range.length);
				if (NSMaxRange(searchRange) > completeStringLength) {
					searchRange = NSMakeRange(beginLocationInMultiLine, completeStringLength - beginLocationInMultiLine);
				}
				
				beginning = [completeString rangeOfString:beginInstruction options:NSLiteralSearch range:searchRange].location;
				if (beginning == NSNotFound) {
					break;
				}
				[completeDocumentScanner setScanLocation:beginning];
				if (![completeDocumentScanner scanUpToString:endInstruction intoString:nil] || [completeDocumentScanner scanLocation] >= completeStringLength) {
					if (shouldOnlyColourTillTheEndOfLine) {
						[completeDocumentScanner setScanLocation:NSMaxRange([completeString lineRangeForRange:NSMakeRange(beginning, 0)])];
					} else {
						[completeDocumentScanner setScanLocation:completeStringLength];
					}
				} else {
					if ([completeDocumentScanner scanLocation] + searchSyntaxLength <= completeStringLength) {
						[completeDocumentScanner setScanLocation:[completeDocumentScanner scanLocation] + searchSyntaxLength];
					}
				}
				
				[self setColour:instructionsColour range:NSMakeRange(beginning, [completeDocumentScanner scanLocation] - beginning)];
				if ([completeDocumentScanner scanLocation] > maxRange) {
					break;
				}
				beginLocationInMultiLine = [completeDocumentScanner scanLocation];
			}
		}
		
		
		// Keywords
		if (DO_COLOUR_KEYWORDS && [keywords count] != 0) 
		{
			[scanner setScanLocation:0];
			while (![scanner isAtEnd]) 
			{
				[scanner scanUpToCharactersFromSet:keywordStartCharacterSet intoString:nil];
				beginning = [scanner scanLocation];
				if ((beginning + 1) < searchStringLength) 
					[scanner setScanLocation:(beginning + 1)];
				
				[scanner scanUpToCharactersFromSet:keywordEndCharacterSet intoString:nil];
				
				end = [scanner scanLocation];
				
				if (end > searchStringLength || beginning == end) 
					break;
				
				
				if (!keywordsCaseSensitive) 
					keywordTestString = [[completeString substringWithRange:NSMakeRange(beginning + rangeLocation, end - beginning)] lowercaseString];
				else
					keywordTestString = [completeString substringWithRange:NSMakeRange(beginning + rangeLocation, end - beginning)];
				
				if ([keywords containsObject:keywordTestString]) 
				{
					if (!recolourKeywordIfAlreadyColoured) 
					{
						if ([[customLayoutManager temporaryAttributesAtCharacterIndex:beginning + rangeLocation effectiveRange:NULL] isEqualToDictionary:commandsColour]) 
							continue;
					}	
					[self setColour:keywordsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
				}
			}
		}
		
		
		// Autocomplete
		if (DO_COLOUR_AUTOCOMPLETE && [autocompleteWords count] != 0) 
		{
			[scanner setScanLocation:0];
			while (![scanner isAtEnd]) 
			{
				[scanner scanUpToCharactersFromSet:keywordStartCharacterSet intoString:nil];
				beginning = [scanner scanLocation];
				if ((beginning + 1) < searchStringLength) 
					[scanner setScanLocation:(beginning + 1)];
				
				[scanner scanUpToCharactersFromSet:keywordEndCharacterSet intoString:nil];
				
				end = [scanner scanLocation];
				if (end > searchStringLength || beginning == end) 
					break;
				
				if (!keywordsCaseSensitive) 
					autocompleteTestString = [[completeString substringWithRange:NSMakeRange(beginning + rangeLocation, end - beginning)] lowercaseString];
				else
					autocompleteTestString = [completeString substringWithRange:NSMakeRange(beginning + rangeLocation, end - beginning)];
		
				if ([autocompleteWords containsObject:autocompleteTestString]) 
				{
					if (!recolourKeywordIfAlreadyColoured) 
					{
						if ([[customLayoutManager temporaryAttributesAtCharacterIndex:beginning + rangeLocation effectiveRange:NULL] isEqualToDictionary:commandsColour]) 
							continue;
					}	
					
					[self setColour:autocompleteWordsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
				}
			}
		}
		
		
		// Variables
		if (DO_COLOUR_VARIABLES && beginVariable != nil) 
		{
			[scanner setScanLocation:0];
			while (![scanner isAtEnd]) {
				[scanner scanUpToCharactersFromSet:beginVariable intoString:nil];
				beginning = [scanner scanLocation];
				if (beginning + 1 < searchStringLength) {
					if ([firstSingleLineComment isEqualToString:@"%"] && [searchString characterAtIndex:beginning + 1] == '%') { // To avoid a problem in LaTex with \%
						if ([scanner scanLocation] < searchStringLength) {
							[scanner setScanLocation:beginning + 1];
						}
						continue;
					}
				}
				endOfLine = NSMaxRange([searchString lineRangeForRange:NSMakeRange(beginning, 0)]);
				if (![scanner scanUpToCharactersFromSet:endVariable intoString:nil] || [scanner scanLocation] >= endOfLine) {
					[scanner setScanLocation:endOfLine];
					length = [scanner scanLocation] - beginning;
				} else {
					length = [scanner scanLocation] - beginning;
					if ([scanner scanLocation] < searchStringLength) {
						[scanner setScanLocation:[scanner scanLocation] + 1];
					}
				}
				
				[self setColour:variablesColour range:NSMakeRange(beginning + rangeLocation, length)];
			}
		}	
		
		
		// Second string, first pass
		if (DO_COLOUR_STRINGS && ![secondString isEqualToString:@""]) {
			@try {
				secondStringMatcher = [[ICUMatcher alloc] initWithPattern:secondStringPattern overString:searchString];
			}
			@catch (NSException *exception) {
				return;
			}
			
			while ([secondStringMatcher findNext]) {
				foundRange = [secondStringMatcher rangeOfMatch];
				[self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
			}
		}
		
		
		// First string
		if (DO_COLOUR_STRINGS && ![firstString isEqualToString:@""]) {
			@try {
				firstStringMatcher = [[ICUMatcher alloc] initWithPattern:firstStringPattern overString:searchString];
			}
			@catch (NSException *exception) {
				return;
			}
			
			while ([firstStringMatcher findNext]) {
				foundRange = [firstStringMatcher rangeOfMatch];
				if ([[customLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
					continue;
				}
				[self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
			}
		}
		
		
		// Attributes
		if (DO_COLOUR_ATTRIBUTES) {
			[scanner setScanLocation:0];
			while (![scanner isAtEnd]) {
				[scanner scanUpToString:@" " intoString:nil];
				beginning = [scanner scanLocation];
				if (beginning + 1 < searchStringLength) {
					[scanner setScanLocation:beginning + 1];
				} else {
					break;
				}
				if (![[customLayoutManager temporaryAttributesAtCharacterIndex:(beginning + rangeLocation) effectiveRange:NULL] isEqualToDictionary:commandsColour]) {
					continue;
				}
				
				[scanner scanCharactersFromSet:attributesCharacterSet intoString:nil];
				end = [scanner scanLocation];
				
				if (end + 1 < searchStringLength) {
					[scanner setScanLocation:[scanner scanLocation] + 1];
				}
				
				if ([completeString characterAtIndex:end + rangeLocation] == '=') {
					[self setColour:attributesColour range:NSMakeRange(beginning + rangeLocation, end - beginning)];
				}
			}
		}
		
		
		// First single-line comment
		if (DO_COLOUR_COMMENTS && ![firstSingleLineComment isEqualToString:@""]) {
			[scanner setScanLocation:0];
			searchSyntaxLength = [firstSingleLineComment length];
			while (![scanner isAtEnd]) {
				[scanner scanUpToString:firstSingleLineComment intoString:nil];
				beginning = [scanner scanLocation];
				if ([firstSingleLineComment isEqualToString:@"//"]) {
					if (beginning > 0 && [searchString characterAtIndex:beginning - 1] == ':') {
						[scanner setScanLocation:beginning + 1];
						continue; // To avoid http:// ftp:// file:// etc.
					}
				} else if ([firstSingleLineComment isEqualToString:@"#"]) {
					if (searchStringLength > 1) {
						rangeOfLine = [searchString lineRangeForRange:NSMakeRange(beginning, 0)];
						if ([searchString rangeOfString:@"#!" options:NSLiteralSearch range:rangeOfLine].location != NSNotFound) {
							[scanner setScanLocation:NSMaxRange(rangeOfLine)];
							continue; // Don't treat the line as a comment if it begins with #!
						} else if ([searchString characterAtIndex:beginning - 1] == '$') {
							[scanner setScanLocation:beginning + 1];
							continue; // To avoid $#
						} else if ([searchString characterAtIndex:beginning - 1] == '&') {
							[scanner setScanLocation:beginning + 1];
							continue; // To avoid &#
						}
					}
				} else if ([firstSingleLineComment isEqualToString:@"%"]) {
					if (searchStringLength > 1) {
						if ([searchString characterAtIndex:beginning - 1] == '\\') {
							[scanner setScanLocation:beginning + 1];
							continue; // To avoid \% in LaTex
						}
					}
				} 
				if (beginning + rangeLocation + searchSyntaxLength < completeStringLength) {
					if ([[customLayoutManager temporaryAttributesAtCharacterIndex:beginning + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
						[scanner setScanLocation:beginning + 1];
						continue; // If the comment is within a string disregard it
					}
				}
				endOfLine = NSMaxRange([searchString lineRangeForRange:NSMakeRange(beginning, 0)]);
				[scanner setScanLocation:endOfLine];
				
				[self setColour:commentsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
			}
		}
		
		
		// Second single-line comment
		if (DO_COLOUR_COMMENTS && ![secondSingleLineComment isEqualToString:@""]) {
			[scanner setScanLocation:0];
			searchSyntaxLength = [secondSingleLineComment length];
			while (![scanner isAtEnd]) {
				[scanner scanUpToString:secondSingleLineComment intoString:nil];
				beginning = [scanner scanLocation];
				
				if ([secondSingleLineComment isEqualToString:@"//"]) {
					if (beginning > 0 && [searchString characterAtIndex:beginning - 1] == ':') {
						[scanner setScanLocation:beginning + 1];
						continue; // To avoid http:// ftp:// file:// etc.
					}
				} else if ([secondSingleLineComment isEqualToString:@"#"]) {
					if (searchStringLength > 1) {
						rangeOfLine = [searchString lineRangeForRange:NSMakeRange(beginning, 0)];
						if ([searchString rangeOfString:@"#!" options:NSLiteralSearch range:rangeOfLine].location != NSNotFound) {
							[scanner setScanLocation:NSMaxRange(rangeOfLine)];
							continue; // Don't treat the line as a comment if it begins with #!
						} else if ([searchString characterAtIndex:beginning - 1] == '$') {
							[scanner setScanLocation:beginning + 1];
							continue; // To avoid $#
						} else if ([searchString characterAtIndex:beginning - 1] == '&') {
							[scanner setScanLocation:beginning + 1];
							continue; // To avoid &#
						}
					}
				}
				if (beginning + rangeLocation + searchSyntaxLength < completeStringLength) {
					if ([[customLayoutManager temporaryAttributesAtCharacterIndex:beginning + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
						[scanner setScanLocation:beginning + 1];
						continue; // If the comment is within a string disregard it
					}
				}
				endOfLine = NSMaxRange([searchString lineRangeForRange:NSMakeRange(beginning, 0)]);
				[scanner setScanLocation:endOfLine];
				
				[self setColour:commentsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
			}
		}
		
		
		// First multi-line comment
		if (DO_COLOUR_COMMENTS && ![beginFirstMultiLineComment isEqualToString:@""]) {
			
			beginLocationInMultiLine = [completeString rangeOfString:beginFirstMultiLineComment options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
			endLocationInMultiLine = [completeString rangeOfString:endFirstMultiLineComment options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
			if (beginLocationInMultiLine == NSNotFound || (endLocationInMultiLine != NSNotFound && beginLocationInMultiLine < endLocationInMultiLine)) {
				beginLocationInMultiLine = rangeLocation;
			}			
			[completeDocumentScanner setScanLocation:beginLocationInMultiLine];
			searchSyntaxLength = [endFirstMultiLineComment length];
			
			while (![completeDocumentScanner isAtEnd]) {
				searchRange = NSMakeRange(beginLocationInMultiLine, range.length);
				if (NSMaxRange(searchRange) > completeStringLength) {
					searchRange = NSMakeRange(beginLocationInMultiLine, completeStringLength - beginLocationInMultiLine);
				}
				beginning = [completeString rangeOfString:beginFirstMultiLineComment options:NSLiteralSearch range:searchRange].location;
				if (beginning == NSNotFound) {
					break;
				}
				[completeDocumentScanner setScanLocation:beginning];
				if (beginning + 1 < completeStringLength) {
					if ([[customLayoutManager temporaryAttributesAtCharacterIndex:beginning effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
						[completeDocumentScanner setScanLocation:beginning + 1];
						beginLocationInMultiLine++;
						continue; // If the comment is within a string disregard it
					}
				}
				if (![completeDocumentScanner scanUpToString:endFirstMultiLineComment intoString:nil] || [completeDocumentScanner scanLocation] >= completeStringLength) {
					if (shouldOnlyColourTillTheEndOfLine) {
						[completeDocumentScanner setScanLocation:NSMaxRange([completeString lineRangeForRange:NSMakeRange(beginning, 0)])];
					} else {
						[completeDocumentScanner setScanLocation:completeStringLength];
					}
					length = [completeDocumentScanner scanLocation] - beginning;
				} else {
					if ([completeDocumentScanner scanLocation] < completeStringLength)
						[completeDocumentScanner setScanLocation:[completeDocumentScanner scanLocation] + searchSyntaxLength];
					length = [completeDocumentScanner scanLocation] - beginning;
					if ([endFirstMultiLineComment isEqualToString:@"-->"]) {
						[completeDocumentScanner scanUpToCharactersFromSet:letterCharacterSet intoString:nil]; // Search for the first letter after -->
						if ([completeDocumentScanner scanLocation] + 6 < completeStringLength) {// Check if there's actually room for a </script>
							if ([completeString rangeOfString:@"</script>" options:NSCaseInsensitiveSearch range:NSMakeRange([completeDocumentScanner scanLocation] - 2, 9)].location != NSNotFound || [completeString rangeOfString:@"</style>" options:NSCaseInsensitiveSearch range:NSMakeRange([completeDocumentScanner scanLocation] - 2, 8)].location != NSNotFound) {
								beginLocationInMultiLine = [completeDocumentScanner scanLocation];
								continue; // If the comment --> is followed by </script> or </style> it is probably not a real comment
							}
						}
						[completeDocumentScanner setScanLocation:beginning + length]; // Reset the scanner position
					}
				}
				
				[self setColour:commentsColour range:NSMakeRange(beginning, length)];
				
				if ([completeDocumentScanner scanLocation] > maxRange) {
					break;
				}
				beginLocationInMultiLine = [completeDocumentScanner scanLocation];
			}
		}
		
		
		// Second multi-line comment
		if (DO_COLOUR_COMMENTS && ![beginSecondMultiLineComment isEqualToString:@""]) 
		{
			
			beginLocationInMultiLine = rangeLocation;
			[completeDocumentScanner setScanLocation:beginLocationInMultiLine];
			searchSyntaxLength = [endSecondMultiLineComment length];
			
			while (![completeDocumentScanner isAtEnd]) {
				searchRange = NSMakeRange(beginLocationInMultiLine, range.length);
				if (NSMaxRange(searchRange) > completeStringLength) {
					searchRange = NSMakeRange(beginLocationInMultiLine, completeStringLength - beginLocationInMultiLine);
				}
				beginning = [completeString rangeOfString:beginSecondMultiLineComment options:NSLiteralSearch range:searchRange].location;
				if (beginning == NSNotFound) {
					break;
				}
				[completeDocumentScanner setScanLocation:beginning];
				if (beginning + 1 < completeStringLength) {
					if ([[customLayoutManager temporaryAttributesAtCharacterIndex:beginning effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
						[completeDocumentScanner setScanLocation:beginning + 1];
						beginLocationInMultiLine++;
						continue; // If the comment is within a string disregard it
					}
				}
				
				if (![completeDocumentScanner scanUpToString:endSecondMultiLineComment intoString:nil] || [completeDocumentScanner scanLocation] >= completeStringLength) {
					if (shouldOnlyColourTillTheEndOfLine) {
						[completeDocumentScanner setScanLocation:NSMaxRange([completeString lineRangeForRange:NSMakeRange(beginning, 0)])];
					} else {
						[completeDocumentScanner setScanLocation:completeStringLength];
					}
					length = [completeDocumentScanner scanLocation] - beginning;
				} else {
					if ([completeDocumentScanner scanLocation] < completeStringLength)
						[completeDocumentScanner setScanLocation:[completeDocumentScanner scanLocation] + searchSyntaxLength];
					length = [completeDocumentScanner scanLocation] - beginning;
					if ([endSecondMultiLineComment isEqualToString:@"-->"]) {
						[completeDocumentScanner scanUpToCharactersFromSet:letterCharacterSet intoString:nil]; // Search for the first letter after -->
						if ([completeDocumentScanner scanLocation] + 6 < completeStringLength) { // Check if there's actually room for a </script>
							if ([completeString rangeOfString:@"</script>" options:NSCaseInsensitiveSearch range:NSMakeRange([completeDocumentScanner scanLocation] - 2, 9)].location != NSNotFound || [completeString rangeOfString:@"</style>" options:NSCaseInsensitiveSearch range:NSMakeRange([completeDocumentScanner scanLocation] - 2, 8)].location != NSNotFound) {
								beginLocationInMultiLine = [completeDocumentScanner scanLocation];
								continue; // If the comment --> is followed by </script> or </style> it is probably not a real comment
							}
						}
						[completeDocumentScanner setScanLocation:beginning + length]; // Reset the scanner position
					}
				}
				[self setColour:commentsColour range:NSMakeRange(beginning, length)];
				
				if ([completeDocumentScanner scanLocation] > maxRange) {
					break;
				}
				beginLocationInMultiLine = [completeDocumentScanner scanLocation];
			}
		}
		
		
		// Second string, second pass
		if (DO_COLOUR_STRINGS && ![secondString isEqualToString:@""]) 
		{
			@try {
				[secondStringMatcher reset];
			}
			@catch (NSException *exception) {
				return;
			}
			
			while ([secondStringMatcher findNext]) {
				foundRange = [secondStringMatcher rangeOfMatch];
				if ([[customLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour] || [[customLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:commentsColour]) {
					continue;
				}
				[self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
			}
		}
		
	}
	@catch (NSException *exception) 
	{
		//Log(exception);
	}
	//[scanner release];
	//[completeDocumentScanner release];
	
}


- (void)setColour:(NSDictionary *)colourDictionary range:(NSRange)range
{
	[customLayoutManager setTemporaryAttributes:colourDictionary forCharacterRange:range];
}


- (void)highlightLineRange:(NSRange)lineRange
{
	if (lineRange.location == lastLineHighlightRange.location && lineRange.length == lastLineHighlightRange.length) {
		return;
	}
	
	[customLayoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:lastLineHighlightRange];
		
	[self pageRecolour];
	
	[customLayoutManager addTemporaryAttributes:lineHighlightColour forCharacterRange:lineRange];
	lastLineHighlightRange = lineRange;
}


#pragma mark -
#pragma mark Delegates

- (void)textDidChange:(NSNotification *)notification
{
	if (reactToChanges == NO) 
		return;
	
	TPSyntaxTextView *textView = (TPSyntaxTextView *)[notification object];
		
	if (HIGHLIGHT_CURRENT_LINE) 
		[self highlightLineRange:[completeString lineRangeForRange:[textView selectedRange]]];
	else 
		[self pageRecolourTextView:textView];
	
	if (autocompleteWordsTimer != nil) 
	{
		[autocompleteWordsTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:AUTOCOMPLETE_DELAY]];
	} 
	//else if (SUGGEST_AUTOCOMPLETE) 
	else if ([owner suggestAutocomplete])
	{
		autocompleteWordsTimer = [NSTimer scheduledTimerWithTimeInterval:AUTOCOMPLETE_DELAY target:self selector:@selector(autocompleteWordsTimerSelector:) userInfo:textView repeats:NO];
	}
	
}


- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
	if (reactToChanges == NO) {
		return;
	}
	
	completeStringLength = [completeString length];
	if (completeStringLength == 0) {
		return;
	}
	
	TPSyntaxTextView *textView = [aNotification object];
	editedRange = [textView selectedRange];
	
	if (HIGHLIGHT_CURRENT_LINE) 
		[self highlightLineRange:[completeString lineRangeForRange:editedRange]];
	
	
	if (!SHOW_MATCHING_BRACES) 
		return;
	
	
	cursorLocation = editedRange.location;
	differenceBetweenLastAndPresent = cursorLocation - lastCursorLocation;
	lastCursorLocation = cursorLocation;
	
	// If the difference is more than one, they've moved the cursor with the mouse or it has been moved by resetSelectedRange below and we shouldn't check for matching braces then
	if (differenceBetweenLastAndPresent != 1 && differenceBetweenLastAndPresent != -1) 
		return; 
	
	// Check if the cursor has moved forward
	if (differenceBetweenLastAndPresent == 1)  
		cursorLocation--;
	
	if (cursorLocation == completeStringLength) 
		return;
	
	characterToCheck = [completeString characterAtIndex:cursorLocation];
	skipMatchingBrace = 0;
	
	if (characterToCheck == ')') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '(') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ')') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == ']') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '[') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ']') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '}') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '{') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '}') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '>') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '<') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '>') {
				skipMatchingBrace++;
			}
		}
	}
}


- (NSArray *)textView:theTextView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
	if ([keywordsAndAutocompleteWords count] == 0) 
	{
		if (!AUTOCOMPLETE_INCLUDE_STANDARD_WORDS) 
			return [NSArray array];
		else
			return words;
	}
	
	NSString *matchString = [[theTextView string] substringWithRange:charRange];
	NSMutableArray *finalWordsArray = [NSMutableArray arrayWithArray:keywordsAndAutocompleteWords];
	if (AUTOCOMPLETE_INCLUDE_STANDARD_WORDS) 
		[finalWordsArray addObjectsFromArray:words];
	
	
	NSMutableArray *matchArray = [NSMutableArray array];
	NSString *item;
	for (item in finalWordsArray) {
		if ([item rangeOfString:matchString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [item length])].location == 0) {
			[matchArray addObject:item];
		}
	}
	
	// If no standard words are added there's no need to sort it again as it has already been sorted
	if (AUTOCOMPLETE_INCLUDE_STANDARD_WORDS) 
		return [matchArray sortedArrayUsingSelector:@selector(compare:)];
	else
		return matchArray;
	
}

- (void)checkIfCanUndo
{
	// ToDo: look at ths later
}

- (void)autocompleteWordsTimerSelector:(NSTimer *)theTimer
{
	TPSyntaxTextView *textView = [theTimer userInfo];
	selectedRange = [textView selectedRange];
	stringLength = [completeString length];
	if (selectedRange.location <= stringLength && selectedRange.length == 0 && stringLength != 0) {
		if (selectedRange.location == stringLength) { // If we're at the very end of the document
			[textView complete:nil];
		} else {
			unichar characterAfterSelection = [completeString characterAtIndex:selectedRange.location];
			if ([[NSCharacterSet symbolCharacterSet] characterIsMember:characterAfterSelection] || [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:characterAfterSelection] || [[NSCharacterSet punctuationCharacterSet] characterIsMember:characterAfterSelection] || selectedRange.location == stringLength) { // Don't autocomplete if we're in the middle of a word
				[textView complete:nil];
			}
		}
	}
	
	if (autocompleteWordsTimer) {
		[autocompleteWordsTimer invalidate];
		autocompleteWordsTimer = nil;
	}
}
@end