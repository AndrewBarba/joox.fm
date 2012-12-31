//
//  NSString+ID.m
//  joox.fm
//
//  Created by Andrew Barba on 6/30/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "NSString+ID.h"

@implementation NSString (ID)
-(NSString *)ID
{
    return [self stringByAppendingFormat:@"i"];
}
@end
