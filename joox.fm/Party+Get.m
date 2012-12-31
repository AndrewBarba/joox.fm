//
//  Party+Get.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Party+Get.h"
#import "PartyTrack.h"
#import "Vote.h"

@implementation Party (Get)
+(Party *)getPartyByIdentifier:(NSInteger)ID inContext:(NSManagedObjectContext *)context
{
    Party *party = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Party"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %i",ID];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count == 1) {
        party = [matches lastObject];
    }
    
    return party;
}

+(NSArray *)allPartiesInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Party"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    return [context executeFetchRequest:request error:nil];
}

-(void)restart
{
    self.active = @(YES);
    for (PartyTrack *partyTrack in [self.tracks allObjects]) {
        partyTrack.state = @(3);
        for (Vote *vote in [partyTrack.votes allObjects]) {
            [partyTrack.managedObjectContext deleteObject:vote];
        }
        partyTrack.rating = @(0);
    }
}

@end
