//
//  PlaylistTrack+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "PlaylistTrack+Create.h"
#import "ListTrack+Create.h"
#import "Playlist+Get.h"
#import "User+Get.h"
#import "Track+Get.h"
#import "NSDictionary+JXFM.h"
#import "Vote+Create.h"

@implementation PlaylistTrack (Create)

+(void)createListTrackWithTrack:(Track *)track inList:(JooxList *)list fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    PlaylistTrack *playlistTrack = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PlaylistTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"track = %@ AND list = %@",track,list];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count >= 1) {
        playlistTrack = [matches lastObject];
    } else {
        playlistTrack = [NSEntityDescription insertNewObjectForEntityForName:@"PlaylistTrack" inManagedObjectContext:context];
        [playlistTrack initWithList:list andUserID:[dict[@"user_id"] integerValue] andTrack:track inContext:context];
    }
    
    playlistTrack.timestamp = [dict timestamp];
    playlistTrack.rating = @([dict[@"rating"] integerValue]);
    for (NSDictionary *vote in dict[@"votes"]) {
        [Vote createVoteForTrack:playlistTrack fromDictionary:vote inContext:context];
    }
}

+(void)addTrack:(Track *)track toList:(JooxList *)list byUser:(NSString *)fb inContext:(NSManagedObjectContext *)context
{
    PlaylistTrack *listTrack = [NSEntityDescription insertNewObjectForEntityForName:@"PlaylistTrack" inManagedObjectContext:context];
    listTrack.list = list;
    listTrack.user  = [User getUserByFB:fb inContext:context];
    listTrack.track = track;
    listTrack.track.timestamp = [NSDate date];
    listTrack.rating = @(0);
    listTrack.timestamp = [track timestamp];
}

@end
