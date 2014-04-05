#import <Cocoa/Cocoa.h>

@interface TPBusySheetController : NSWindowController
{
	IBOutlet NSTextField *message;
	IBOutlet NSProgressIndicator *activity;
	IBOutlet NSButton *cancel;
	
	NSString *messageText;
	BOOL allowCancel;

	NSWindow *window;
}

- (void) showSheetForWindow:(NSWindow *)aWindow withMessage:(NSString *) aMessage allowCancel:(BOOL) aAllowCancel;
- (void) hideSheet;
- (void) showSheet;

- (IBAction) cancel:(id)sender;

- (void)setMessageText:(NSString *)text;

@end
