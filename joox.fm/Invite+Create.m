//
//  Invite+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 6/25/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Invite+Create.h"
#import "Joox.h"
#import "NSDictionary+JXFM.h"

@implementation Invite (Create)

+(void)createInviteFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    Invite *invite = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Invite"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@",@([dict[@"id"] integerValue])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count >= 1) {
        invite = [matches lastObject];
        invite.timestamp = [dict timestamp];
    } else {
        invite = [NSEntityDescription insertNewObjectForEntityForName:@"Invite" inManagedObjectContext:context];
        invite.identifier = @([dict[@"id"] integerValue]);
        invite.playlistName = [Joox strip:dict[@"playlist_name"]];
        invite.userName = [Joox strip:dict[@"full_name"]];
        invite.userFB = dict[@"fb"];
        invite.timestamp = [dict timestamp];
        invite.playlistID = @([dict[@"playlist_id"] integerValue]);
    }
}

+(NSArray *)allInvitesInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Invite"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    return [context executeFetchRequest:request error:nil];
}


@end
