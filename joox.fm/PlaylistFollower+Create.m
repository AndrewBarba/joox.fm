//
//  PlaylistFollower+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "PlaylistFollower+Create.h"
#import "User+Get.h"
#import "NSDictionary+JXFM.h"

@implementation PlaylistFollower (Create)
+(void)createListFollowerWithUser:(User *)user inList:(Playlist *)list fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    PlaylistFollower *follower = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ListUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND list = %@",user,list];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if (!matches) {
        NSLog(@"There was an error fetching parties");
    } else if (matches.count >= 1) {
        follower = [matches lastObject];
    } else {
        follower = [NSEntityDescription insertNewObjectForEntityForName:@"PlaylistFollower" inManagedObjectContext:context];
        follower.playlist = list;
        follower.user = user;
        follower.user.timestamp = [NSDate date];
    }
    
    follower.timestamp = [dict timestamp];
    follower.active = [dict[@"active"] boolValue] ? @(1) : nil;
}

+(PlaylistFollower *)getFollower:(NSInteger)userID InList:(NSInteger)listID inContext:(NSManagedObjectContext *)context
{
    PlaylistFollower *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PlaylistFollower"];
    request.predicate = [NSPredicate predicateWithFormat:@"playlist.identifier = %@ AND user.identifier = %@",@(listID),@(userID)];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count > 0) {
        user = [matches lastObject];
    }
    
    return user;
}
@end
