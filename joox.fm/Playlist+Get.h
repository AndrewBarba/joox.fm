//
//  Playlist+Get.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Playlist.h"

@interface Playlist (Get)
+ (Playlist *)getPlaylistByIdentifier:(NSInteger)ID inContext:(NSManagedObjectContext *)context;
+ (NSArray *)allPlaylistsInContext:(NSManagedObjectContext *)context;
+(NSArray *)allTracksInPlaylist:(NSNumber *)ID inContext:(NSManagedObjectContext *)context;
@end
