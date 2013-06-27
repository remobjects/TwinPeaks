//
//  TPVersionHelpers.m
//  Builds
//
//  Created by marc hoffman on 6/21/13.
//
//

#import "TPVersionHelpers.h"

@implementation TPVersionHelpers

+ (BOOL)isIOS6
{
    int osVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    return (osVersion >= 6);
    
}

+ (BOOL)isIOS7
{
    int osVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    return (osVersion >= 7);
    
}



@end
