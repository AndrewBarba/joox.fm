//
//  Activity+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 7/1/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Activity+Create.h"
#import "User+Get.h"
#import "Playlist+Get.h"
#import "Party+Get.h"
#import "Track+Get.h"
#import "JooxList+Get.h"
#import "NSDictionary+JXFM.h"
#import "Joox.h"
#import "ListUser+Get.h"
#import "ListTrack+Get.h"
#import "PlaylistFollower+Create.h"

@implementation Activity (Create)
+(Activity *)activityFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    if ([dict[@"type"] isEqualToString:@"user"] || [dict[@"type"] isEqualToString:@"follower"]) {
        return [Activity userActivityFromDicitonary:dict inContext:context];
    } else {
        return [Activity trackActivityFromDicitonary:dict inContext:context];
    }
}

+(Activity *)userActivityFromDicitonary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    NSInteger userID = [dict[@"user_id"] integerValue];
    NSInteger listID = [dict[@"list_id"] integerValue];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Activity"];
    request.predicate = [NSPredicate predicateWithFormat:
                         @"list.identifier = %@ AND listUser.user.identifier = %@ AND type = %@",
                         @(listID),@(userID),dict[@"type"]];
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    Activity *activity = nil;
    if (matches.count >= 1) {
        activity = [matches lastObject];
    } else {
        activity = [NSEntityDescription insertNewObjectForEntityForName:@"Activity" inManagedObjectContext:context];
        activity.listUser = [ListUser getUser:userID InList:listID inContext:context];
        activity.listFollower = [PlaylistFollower getFollower:userID InList:listID inContext:context];
        activity.timestamp = [dict timestamp];
        activity.type = dict[@"type"];
        activity.list = [JooxList getListByIdentifier:listID inContext:context];
    }
    
    return activity;
}

+(Activity *)trackActivityFromDicitonary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    NSInteger userID = [dict[@"user_id"] integerValue];
    NSInteger trackID = [dict[@"track_id"] integerValue];
    NSInteger listID = [dict[@"list_id"] integerValue];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Activity"];
    request.predicate = [NSPredicate predicateWithFormat:
                         @"type BEGINSWITH[n] %@ AND list.identifier = %i AND listUser.user.identifier = %i AND listTrack.track.identifier = %i",
                         dict[@"type"],listID,userID,trackID];
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    Activity *activity = nil;
    if (matches.count > 0) {
        activity = [matches lastObject];
    } else {
        activity = [NSEntityDescription insertNewObjectForEntityForName:@"Activity" inManagedObjectContext:context];
        activity.listUser = [ListUser getUser:userID InList:listID inContext:context];
        activity.listFollower = [PlaylistFollower getFollower:userID InList:listID inContext:context];
        activity.listTrack = [ListTrack getTrack:trackID InList:listID inContext:context];
        activity.timestamp = [dict timestamp];
        activity.type = dict[@"type"];
        activity.list = [JooxList getListByIdentifier:listID inContext:context];
    }
    
    return activity;
}

@end
