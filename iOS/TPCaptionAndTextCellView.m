//
//  CaptionAndTextCellView.m
//  Bugs
//
//  Created by marc hoffman on 3/19/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import "TPCaptionAndTextCellView.h"


@implementation TPCaptionAndTextCellView

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		self.textAlpha = 1.0;
		//self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#if !RO_TARGET_DOES_ARC
- (void)dealloc
{
	[caption release];
	[text release];
	[color release];
	[super dealloc];
}
#endif

@synthesize caption = caption;
@synthesize text = text;
@synthesize color = color;
@synthesize centered = centered;

- (void) setCaption:(NSString *)aCaption
{
#if !RO_TARGET_DOES_ARC
	[caption release];
	caption = [[aCaption stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];
#else
	caption = [aCaption stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#endif
	[self setNeedsDisplay];
}

- (void) setText:(NSString *)aText
{
#if !RO_TARGET_DOES_ARC
	[text release];
	text = [[aText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];
#else
	text = [aText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#endif
	[self setNeedsDisplay];
}

//@synthesize highlighted = highlighted;
@synthesize textAlpha = textAlpha;

+ (UIFont *)captionFont
{
	return [UIFont boldSystemFontOfSize:13];
}
+ (UIFont*)textFont
{
	return [UIFont systemFontOfSize:13];
}


+ (CGFloat)cellHeightForCaption:(NSString *)caption text:(NSString *)text
{
	return [self cellHeightForCaption:caption text:text width:320];
}

+ (CGFloat)cellHeightForCaption:(NSString *)caption text:(NSString *)text width:(CGFloat)width;
{
	UIFont *captionFont = [self captionFont];
	UIFont *textFont = [self textFont];
	
	CGSize cs = [caption sizeWithFont:captionFont constrainedToSize:CGSizeMake(width-10.0, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize ts = [text sizeWithFont:textFont constrainedToSize:CGSizeMake(width-10.0, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize cs2 = [caption sizeWithFont:captionFont];
	CGSize ts2 = [text sizeWithFont:textFont];
	
	CGFloat height = 0;
	if (ts2.width+cs2.width+15.0 < width-10.0) 
		height = cs2.height+10.0;
	else 
		height = ts.height+cs.height+10;//15.0;

	if (height > 512) height = 512;
	//NSLog(@"rect: %f", height);
	return height;
}

+ (CGFloat)cellHeightForText:(NSString *)text;
{
	CGSize cs = [@"Xy" sizeWithFont:[self captionFont]]; 
	CGSize s = [text sizeWithFont:[self textFont]]; 
	return s.height+cs.height+10.0;
}

- (void)drawRect:(CGRect)rect 
{
	UIColor *mainTextColor = nil;
	UIColor *secondaryTextColor = nil;
	if (self.highlighted) 
	{
		mainTextColor = [UIColor whiteColor];
		secondaryTextColor = mainTextColor;
	}
	else
	{
		mainTextColor = color?color:[[UIColor blackColor] colorWithAlphaComponent:textAlpha];
		secondaryTextColor = color?color:[[UIColor darkGrayColor] colorWithAlphaComponent:textAlpha];
	}
	
	CGRect f = [self frame];
	
	if (!highlighted) 
	{
		//[[self gradientImage] drawInRect:f];
	}
	
	UIFont *captionFont = [[self class ]captionFont];
	UIFont *textFont = [[self class ]textFont];
	
	CGSize cs = [caption sizeWithFont:captionFont constrainedToSize:CGSizeMake(f.size.width-10, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	//CGSize ts = [text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(300.0f, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap]; 

	CGSize cs2 = [caption sizeWithFont:captionFont]; 
	CGSize ts2 = [text sizeWithFont:textFont];//[UIFont systemFontOfSize:13]]; 
	
	if (centered)
	{
		[mainTextColor set];	
		CGRect c = CGRectMake((f.size.width-cs.width)/2, 5.0, f.size.width, cs.height+5.0);
		[caption drawInRect:c withFont:captionFont lineBreakMode:NSLineBreakByWordWrapping];
	}
	else
	{
		[mainTextColor set];	
		CGRect c = CGRectMake(5.0, 5.0, f.size.width-10.0, cs.height+5.0);
		[caption drawInRect:c withFont:captionFont lineBreakMode:NSLineBreakByWordWrapping];
		
		[secondaryTextColor set];
		if (ts2.width+cs2.width+15.0 < f.size.width-10) 
		{
			CGPoint p = CGPointMake(cs.width+10.0, 5.0);
			[text drawAtPoint:p withFont:textFont];
		}
		else
		{
			CGRect r = CGRectMake(5.0, cs.height+5.0, f.size.width-10.0, f.size.height-cs.height-10.0);
			[text drawInRect:r withFont:textFont lineBreakMode:NSLineBreakByWordWrapping];
		}
	}
}

@end
