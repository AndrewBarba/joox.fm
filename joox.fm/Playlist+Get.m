//
//  Playlist+Get.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Playlist+Get.h"

@implementation Playlist (Get)
+(Playlist *)getPlaylistByIdentifier:(NSInteger)ID inContext:(NSManagedObjectContext *)context
{
    Playlist *playlist = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Playlist"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %i",ID];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count == 1) {
        playlist = [matches lastObject];
    }
    
    return playlist;
}

+(NSArray *)allTracksInPlaylist:(NSNumber *)ID inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PlaylistTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"list.identifier = %@",ID];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    return [context executeFetchRequest:request error:nil];
}

+(NSArray *)allPlaylistsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Playlist"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    return [context executeFetchRequest:request error:nil];
}

@end
