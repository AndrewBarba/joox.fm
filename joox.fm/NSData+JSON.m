//
//  NSData+JSON.m
//  joox.fm
//
//  Created by Andrew Barba on 7/23/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "NSData+JSON.h"

@implementation NSData (JSON)
-(id)JSON
{
    return [NSJSONSerialization JSONObjectWithData:self
                                           options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                             error:nil];
}
@end
