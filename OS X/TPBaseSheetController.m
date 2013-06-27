//
//  TPBaseSheetController.m
//  Bugs
//
//  Created by marc hoffman on 8/27/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import "TPBaseSheetController.h"

@implementation TPBaseSheetController

@synthesize delegate = delegate;
@synthesize validated = validated;
@synthesize parentWindow = parentWindow;

- (id)init
{
	NSString *name = [[[self class] className] substringToIndex:[[[self class] className] length]-10];
	return [super initWithWindowNibName:name];
}

- (void)awakeFromNib
{
	[self validate:nil];
}

- (void) showForWindow:(NSWindow *)aWindow
{
	parentWindow = aWindow;
    retainedSelf = self;
	[NSApp beginSheet:[self window] modalForWindow:aWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [[self window] orderOut:[self window]];
    retainedSelf = nil;
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];	
}

- (void)toggleView:(NSView *)view andView:(NSView *)view2 enabled:(BOOL)enabled
{
	if (enabled)
	{
		[[view animator] setAlphaValue:1.0];
		[[view2 animator] setAlphaValue:1.0];
	}
	else
	{
		[[view animator] setAlphaValue:DISABLED_ALPHA];
		[[view2 animator] setAlphaValue:DISABLED_ALPHA];
	}

}

- (BOOL)validateView:(NSView *)view forCondition:(BOOL)condition
{
	if (!condition)
	{
		self.validated = NO;
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowColor:[NSColor redColor]];
		[shadow setShadowOffset:NSMakeSize(0,0)];
		[shadow setShadowBlurRadius:4.0];
		[view setShadow:shadow];
	}
	else
	{
		[view setShadow:nil];
	}
	return condition;
}

- (IBAction)validate:(id)sender
{
	self.validated = YES;
}

#ifdef TP_DATAABSTRACT
- (void)setPopup:(NSPopUpButton *)popup
	   fromField:(NSString*)field 
		   inRow:(DADataTableRow *)row 
 withLookupField:(NSString *)lookupField 
		 inTable:(DADataTable *)lookupTable
{
	id value = [row valueForKey:field];
	if (value)
	{
		NSString *stringValue = [[[lookupTable indexForField:@"ID"] rowForIndexValue:value] valueForKey:lookupField];
		[popup selectItemWithTitle:stringValue];
		if (![popup selectedItem])
		{
			NSLog(@"Could not pre-select item '%@' - value not found in %@ lookup popup.", stringValue, [lookupTable name]);
		}
	}
}

- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromLookupTable:(DADataTable *)table keyField:(NSString*)keyField lookupField:(NSString*)lookupField popup:(NSPopUpButton *)popup dropAfterSeparator:(NSString *)separator
{
	DADataTableRow *p;
	NSString *title = [[popup selectedItem] title];
    
    NSRange r = [title rangeOfString:separator];
    if (r.location != NSNotFound)
    {
        title = [title substringToIndex:r.location];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
	if (title && [title compare:NO_CHANGE_TEXT] == NSOrderedSame)
	{
		// no change
	}
	else 
	{
		if (title && [title length] > 0)
		{
			p = [[table indexForField:lookupField] rowForIndexValue:title];
			if (p) [row setValue:[p valueForKey:keyField] forKey:name];
		}
		else
		{
			[row setValue:nil forKey:name];
		}
	}
}

- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromLookupTable:(DADataTable *)table keyField:(NSString*)keyField lookupField:(NSString*)lookupField popup:(NSPopUpButton *)popup
{
	DADataTableRow *p;
	NSString *title = [[popup selectedItem] title];
	if (title && [title compare:NO_CHANGE_TEXT] == NSOrderedSame)
	{
		// no change
	}
	else 
	{
		if (title && [title length] > 0)
		{
			p = [[table indexForField:lookupField] rowForIndexValue:title];
			if (p) [row setValue:[p valueForKey:keyField] forKey:name];
		}
		else
		{
			[row setValue:nil forKey:name];
		}
	}
}

- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromLookupTable:(DADataTable *)table lookupField:(NSString*)lookupField popup:(NSPopUpButton *)popup
{
	[self setField:name
			 onRow:row 
   fromLookupTable:table 
		  keyField:@"ID"
	   lookupField:lookupField 
			 popup:popup];
}

- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromLookupTable:(DADataTable *)table popup:(NSPopUpButton *)popup
{
	[self setField:name onRow:row fromLookupTable:table lookupField:@"Name" popup:popup];
}

- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromEdit:(NSTextField *)edit
{
	NSString *value = [edit stringValue];
	if ([value length] > 0)
		[row setValue:value forKey:name];
	else
		[row setValue:[DANull nullValue] forKey:name];
}
#endif

#pragma mark Drag and Drop Handling

//
// Standard implementation shared by all sheets that allow dropping of files
//

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
	return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
	return NSDragOperationCopy;
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
	return YES;
}

- (NSArray *)getFilenamesForDragOperation:(id < NSDraggingInfo >)info
{
	//ToDo: also support NSFileNamesPromisePboardType!
	NSPasteboard* pboard = [info draggingPasteboard];
	return [pboard propertyListForType:NSFilenamesPboardType];
}

- (void)enableAsFileDragDestination
{
	[self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType, NSFilenamesPboardType, nil]];
}
@end
