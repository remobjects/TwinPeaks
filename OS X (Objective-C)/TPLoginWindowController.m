#import "TPLoginWindowController.h"

@implementation TPLoginWindowController

- (id) init
{
	self = [super initWithWindowNibName:@"TPLoginWindowController"];
	if (self)
	{
	}
	return self;	
}

- (void)awakeFromNib
{
	if (loginNameTemp) [loginNameField setStringValue:loginNameTemp];
	if (passwordTemp) [passwordField setStringValue:passwordTemp];	
	
	if (loginNameTemp)
		[self.window makeFirstResponder:passwordField];
	else
		[self.window makeFirstResponder:loginNameField];
}

- (void) dealloc
{
	[loginNameTemp release];
	[passwordTemp release];
	[parentWindow release];
	[super dealloc];
}

- (NSString *) loginName
{
	return [loginNameField stringValue];
}

- (NSString *) password
{
	return [passwordField stringValue];
}

- (void) setLoginName:(NSString *)aLoginName
{
	loginNameTemp = [aLoginName retain];
	[loginNameField setStringValue:aLoginName];
}

- (void) setPassword:(NSString *)aPassword
{
	passwordTemp = [aPassword retain];
	[passwordField setStringValue:aPassword];
}

- (IBAction) onLoginClick:(id)sender
{
	done = YES;
	[NSApp stopModal];
}

- (IBAction) onCancelClick:(id)sender
{
	done = NO;
	[NSApp stopModal];
}

- (BOOL) promptForLogin:(NSWindow *)aParentwindow
{
	done = NO;
	parentWindow = [aParentwindow retain];
	
	if ([aParentwindow isVisible])
	{
		[NSApp beginSheet:[self window] modalForWindow:aParentwindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
		@try
		{
			[NSApp runModalForWindow: [self window]];
		}
		@finally
		{
			[NSApp endSheet:[self window]];	
			[[self window] orderOut:parentWindow];
		}
	}
	else
	{
		NSModalSession s = [NSApp beginModalSessionForWindow:[self window]];
		[[self window] display];
		@try
		{
			[NSApp runModalForWindow: [self window]];
		}
		@finally 
		{
			[NSApp endModalSession:s];
			[[self window] close];
		}
	}
	
	return done;
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [[self window] orderOut:parentWindow];
}

@end
