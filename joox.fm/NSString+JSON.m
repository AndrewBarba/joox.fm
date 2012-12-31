//
//  NSString+JSON.m
//  joox.fm
//
//  Created by Andrew Barba on 7/23/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "NSString+JSON.h"
@implementation NSString (JSON)
-(id)JSON
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] JSON];
}
@end
