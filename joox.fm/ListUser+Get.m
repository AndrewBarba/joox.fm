//
//  ListUser+Get.m
//  joox.fm
//
//  Created by Andrew Barba on 7/7/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ListUser+Get.h"

@implementation ListUser (Get)
+(ListUser *)getUser:(NSInteger)userID InList:(NSInteger)listID inContext:(NSManagedObjectContext *)context
{
    ListUser *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ListUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"list.identifier = %@ AND user.identifier = %@",@(listID),@(userID)];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count > 0) {
        user = [matches lastObject];
    }
    
    return user;
}
@end
