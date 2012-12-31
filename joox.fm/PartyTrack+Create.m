//
//  PartyTrack+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "PartyTrack+Create.h"
#import "ListTrack+Create.h"
#import "Party.h"
#import "User.h"
#import "Track.h"
#import "NSDictionary+JXFM.h"
#import "Vote+Create.h"

@implementation PartyTrack (Create)

+(void)createListTrackWithTrack:(Track *)track inList:(JooxList *)list fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    PartyTrack *partyTrack = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PartyTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"track = %@ AND list = %@",track,list];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count >= 1) {
        partyTrack = [matches lastObject];
    } else {
        partyTrack = [NSEntityDescription insertNewObjectForEntityForName:@"PartyTrack" inManagedObjectContext:context];
        [partyTrack initWithList:list andUserID:[dict[@"user_id"] integerValue] andTrack:track inContext:context];
    }
    
    partyTrack.state = @([dict[@"state"] integerValue]);
    partyTrack.rating = @([dict[@"rating"] integerValue]);
    partyTrack.timestamp = [dict timestamp];
    for (NSDictionary *vote in dict[@"votes"]) {
        [Vote createVoteForTrack:partyTrack fromDictionary:vote inContext:context];
    }
}

@end
