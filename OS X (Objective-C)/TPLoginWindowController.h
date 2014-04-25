#import <Cocoa/Cocoa.h>

@interface TPLoginWindowController : NSWindowController {

	IBOutlet NSTextField *loginNameField;
	IBOutlet NSTextField *passwordField;

	BOOL done;
	NSWindow *parentWindow;
	
	NSString *loginNameTemp;
	NSString *passwordTemp;
	
}

@property (copy) NSString *loginName;
@property (copy) NSString *password;

- (IBAction) onLoginClick:(id)sender;
- (IBAction) onCancelClick:(id)sender;

- (BOOL) promptForLogin:(NSWindow *)aParentwindow;

@end
