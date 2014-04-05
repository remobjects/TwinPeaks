#import "TPBusySheetController.h"

@implementation TPBusySheetController

- (id) init
{
	self = [super initWithWindowNibName:@"TPBusySheetController"];
	if (self)
	{
	}
	return self;	
}

- (void)windowDidLoad
{
	[activity startAnimation:self];
	[cancel setEnabled:allowCancel];
	[cancel setHidden:!allowCancel];
	[message setStringValue:messageText];
	
}

- (IBAction) cancel:(id)sender
{
	//todo
}

- (void)setMessageText:(NSString *)text;
{
	[message setStringValue:text];
}

- (void) showSheetForWindow:(NSWindow *)aWindow withMessage:(NSString *) aMessage allowCancel:(BOOL) aAllowCancel
{
	window = [aWindow retain];
	messageText = [aMessage retain];
	allowCancel = aAllowCancel;
	[NSApp beginSheet:[self window] modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void) hideSheet
{
	[NSApp endSheet:[self window]];
	[activity stopAnimation:self];
}

- (void) showSheet
{
	[NSApp beginSheet:[self window] modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}


- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [[self window] orderOut:window];
}

- (void) dealloc
{
	[window release]; window = nil;
	[messageText release];
	[super dealloc];
}

@end
