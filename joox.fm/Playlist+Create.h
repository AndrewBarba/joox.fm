//
//  Playlist+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Playlist.h"

@interface Playlist (Create)
+(Playlist *)createPlaylistWithDicitonary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
@end
