//
//  User+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "User+Create.h"
#import "Joox.h"
#import "NSDictionary+JXFM.h"

@implementation User (Create)

+(User *)createUserFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@",@([dict[@"id"] integerValue])];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching users");
        return nil;
    } else if (matches.count >= 1) {
        user = [matches lastObject];
    } else {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.identifier = @([dict[@"id"] integerValue]);
        user.fb = dict[@"fb"];
        user.timestamp = [NSDate date];
    }
    
    user.firstName = [Joox strip:[dict firstName]];
    user.lastName  = [Joox strip:[dict lastName]];
    user.fullName  = [Joox strip:[dict fullName]];
    if ([dict[@"id"] isEqualToString:[Joox getUserInfo][@"id"]]) user.fullName = @"You";
    user.email = dict[@"email"];
    
    return user;
}

+(void)createUserFromFacebook:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"fb = %@",dict[@"id"]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching users");
    } else if (matches.count >= 1) {
        user = [matches lastObject];
        user.fbName = dict[@"username"];
        if (!user.isFriend) user.isFriend = @(YES);
    } else {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.fb = dict[@"id"];
        user.fullName = dict[@"name"];
        user.isFriend = @(YES);
        user.fbName = dict[@"username"];
    }
}

@end
