//
//  Data Abstract for Cocoa
//
//  Copyright RemObjects Software. All rights reserved.
//
//  Using this code requires a valid license for Data Abstract 
//  which can be obtained at http://www.remobjects.com/da
//

#import <Foundation/Foundation.h>


@interface NSArray (TPArrayHelpers)

- (NSDictionary *)arrayPartitionedByKey:(NSString *)key;
- (NSArray *)sortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending;
- (NSArray *)localizedCaseInsensitivelySortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending;

#ifdef TP_DATAABSTRACT
- (NSArray *)selectChangedTables;
#endif

- (id)firstOrNil;

@end
