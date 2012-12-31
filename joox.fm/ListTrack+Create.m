//
//  ListTrack+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 7/11/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ListTrack+Create.h"
#import "User+Get.h"
#import "Track+Get.h"
#import "Joox.h"
#import "NSDictionary+JXFM.h"

@implementation ListTrack (Create)

-(void)initWithList:(JooxList *)list andUserID:(NSInteger)userID andTrack:(Track *)track inContext:(NSManagedObjectContext *)context
{
    self.list = list;
    self.track = track;
    self.user = [User getUserByID:userID inContext:context];
    self.track.timestamp = [NSDate date];
    self.user.timestamp = [NSDate date];
}

+(void)addTrack:(NSDictionary *)track toList:(JooxList *)list inContext:(NSManagedObjectContext *)context
{
    ListTrack *listTrack = nil;
    listTrack = [NSEntityDescription insertNewObjectForEntityForName:@"ListTrack" inManagedObjectContext:context];
    listTrack.list = list;
    listTrack.user  = [User getUserByFB:track[@"fb"] inContext:context];
    listTrack.track = [Track getTrackByIdentifier:[track[@"id"] integerValue] inContext:context];
    listTrack.track.timestamp = [NSDate date];
    listTrack.rating = @([track[@"rating"] integerValue]);
    listTrack.timestamp = [track timestamp];
}

+(void)addTrack:(Track *)track toList:(JooxList *)list byUser:(NSString *)fb inContext:(NSManagedObjectContext *)context
{
    ListTrack *listTrack = nil;
    listTrack = [NSEntityDescription insertNewObjectForEntityForName:@"ListTrack" inManagedObjectContext:context];
    listTrack.list = list;
    listTrack.user  = [User getUserByFB:fb inContext:context];
    listTrack.track = track;
    listTrack.track.timestamp = [NSDate date];
    listTrack.rating = @(0);
    listTrack.timestamp = [track timestamp];
}

-(void)updateTrack:(NSDictionary *)track inContext:(NSManagedObjectContext *)context
{
    self.rating = @([track[@"rating"] integerValue]);
    self.active = @(1);
}

@end
