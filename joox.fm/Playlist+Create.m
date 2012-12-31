//
//  Playlist+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Playlist+Create.h"
#import "Joox.h"
#import "NSDictionary+JXFM.h"

@implementation Playlist (Create)
+(Playlist *)createPlaylistWithDicitonary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    Playlist *playlist = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Playlist"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@",@([dict[@"playlist_id"] integerValue])];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
        return nil;
    } else if (matches.count >= 1) {
        playlist = [matches lastObject];
    } else {
        playlist = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:context];
        playlist.identifier = @([dict[@"playlist_id"] integerValue]);
//        playlist.secret = dict[@"secret"];
        playlist.type = @"playlist";
        playlist.active = @(1);
        playlist.following = [dict[@"following"] integerValue] ? @(YES) : nil;
    }
    
    if ([playlist.version integerValue] != [dict[@"version"] integerValue]) {
        playlist.name = [Joox strip:dict[@"name"]];
        playlist.timestamp = [dict timestamp];
        playlist.version = @([dict[@"version"] integerValue]);
        return playlist;
    } else {
        return nil;
    }
}

@end
