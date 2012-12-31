//
//  ListUser+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 9/9/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ListUser+Create.h"
#import "User.h"
#import "NSDictionary+JXFM.h"

@implementation ListUser (Create)
+(void)createListUserWithUser:(User *)user inList:(JooxList *)list fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    ListUser *listUser = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ListUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND list = %@",user,list];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if (!matches) {
        NSLog(@"There was an error fetching parties");
    } else if (matches.count >= 1) {
        listUser = [matches lastObject];
    } else {
        listUser = [NSEntityDescription insertNewObjectForEntityForName:@"ListUser" inManagedObjectContext:context];
        listUser.list = list;
        listUser.user = user;
        listUser.user.timestamp = [NSDate date];
    }
    
    listUser.timestamp = [dict timestamp];
    listUser.active = [dict[@"active"] boolValue] ? @(1) : nil;
}
@end
