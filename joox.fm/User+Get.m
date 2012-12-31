//
//  User+Get.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "User+Get.h"

@implementation User (Get)
+(User *)getUserByFB:(NSString *)fb inContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"fb = %@",fb];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching users");
    } else if (matches.count == 1) {
        user = [matches lastObject];
    }
    
    return user;
}

+(User *)getUserByFB:(NSString *)fb inPlaylist:(NSNumber *)playlistID inContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ListUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"user.fb = %@ AND list.identifier = %@",fb,playlistID];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching users");
    } else if (matches.count == 1) {
        user = [matches lastObject];
    }
    
    return user;
}

+(User *)getUserByID:(NSInteger)ID inContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@",@(ID)];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching users");
    } else if (matches.count >= 1) {
        user = [matches lastObject];
    }
    
    return user;
}
@end
