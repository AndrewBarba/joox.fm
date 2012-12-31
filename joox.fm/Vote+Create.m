//
//  Vote+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 7/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Vote+Create.h"
#import "User+Get.h"

@implementation Vote (Create)
+(Vote *)createVoteForTrack:(ListTrack *)listTrack fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    Vote *vote = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Vote"];
    request.predicate = [NSPredicate predicateWithFormat:@"track = %@ AND user.identifier = %i",listTrack,[dict[@"user_id"] integerValue]];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    if (matches.count > 0) {
        vote = [matches lastObject];
    } else {
        vote = [NSEntityDescription insertNewObjectForEntityForName:@"Vote" inManagedObjectContext:context];
        vote.track = listTrack;
        vote.user = [User getUserByID:[dict[@"user_id"] integerValue] inContext:context];
    }
    
    return vote;
}

+(void)createVoteForTrack:(ListTrack *)track andUser:(NSString *)fb inContext:(NSManagedObjectContext *)context
{    
    [context performBlockAndWait:^{
        Vote *vote = [NSEntityDescription insertNewObjectForEntityForName:@"Vote" inManagedObjectContext:context];
        vote.track = track;
        vote.user = [User getUserByFB:fb inContext:context];
    }];
}

@end
