//
//  ListTrack+Get.m
//  joox.fm
//
//  Created by Andrew Barba on 7/7/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ListTrack+Get.h"
#import "Vote.h"
#import "User.h"
#import "Joox.h"

@implementation ListTrack (Get)
+(ListTrack *)getTrack:(NSInteger)trackID InList:(NSInteger)listID inContext:(NSManagedObjectContext *)context
{
    ListTrack *track = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ListTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"list.identifier = %i AND track.identifier = %i",listID,trackID];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count > 0) {
        track = [matches lastObject];
    }
    
    return track;
}

-(BOOL)userDidVote:(NSInteger)userID
{
    for (Vote *vote in self.votes) {
        if ([vote.user.identifier integerValue] == userID) return YES;
    }
    return NO;
}

-(BOOL)didUpload
{
    return [[Joox getUserInfo][@"id"] integerValue] == [self.user.identifier integerValue];
}

@end
