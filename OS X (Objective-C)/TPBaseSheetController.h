//
//  TPBaseSheetController.h
//  Bugs
//
//  Created by marc hoffman on 8/27/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#ifdef TP_DATAABSTRACT
#import <DataAbstract/DataAbstract.h>
#endif

#define DISABLED_ALPHA 0.25 
#define NO_CHANGE_TEXT @"-- no change --"

@interface TPBaseSheetController : NSWindowController 
{
	BOOL validated;
	NSWindow *parentWindow;
    
    TPBaseSheetController *retainedSelf;
	
	IBOutlet __unsafe_unretained id delegate;
}

@property (assign) BOOL validated;
@property (unsafe_unretained) id delegate;
@property (readonly)NSWindow *parentWindow;

- (void) showForWindow:(NSWindow *)aWindow;

- (void)toggleView:(NSView *)view andView:(NSView *)view2 enabled:(BOOL)enabled;

- (BOOL)validateView:(NSView *)view forCondition:(BOOL)condition;

- (IBAction)validate:(id)sender;
- (IBAction)cancel:(id)sender;

#ifdef TP_DATAABSTRACT
- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromLookupTable:(DADataTable *)table keyField:(NSString*)keyField lookupField:(NSString*)lookupField popup:(NSPopUpButton *)popup dropAfterSeparator:(NSString *)separator;
- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromLookupTable:(DADataTable *)table keyField:(NSString*)keyField lookupField:(NSString*)lookupField popup:(NSPopUpButton *)popup;
- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromLookupTable:(DADataTable *)table lookupField:(NSString*)lookupField popup:(NSPopUpButton *)popup;
- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromLookupTable:(DADataTable *)table popup:(NSPopUpButton *)popup;
- (void)setField:(NSString *)name onRow:(DADataTableRow *)row fromEdit:(NSTextField *)edit;


- (void)setPopup:(NSPopUpButton *)popup fromField:(NSString*)field inRow:(DADataTableRow *)row withLookupField:(NSString *)lookupField inTable:(DADataTable *)table;
#endif

- (void)enableAsFileDragDestination;

- (NSArray *)getFilenamesForDragOperation:(id < NSDraggingInfo >)info;

@end
