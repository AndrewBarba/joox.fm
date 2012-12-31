//
//  PlaylistFollower+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "PlaylistFollower.h"

@interface PlaylistFollower (Create)
+(void)createListFollowerWithUser:(User *)user inList:(Playlist *)list fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+(PlaylistFollower *)getFollower:(NSInteger)userID InList:(NSInteger)listID inContext:(NSManagedObjectContext *)context;
@end
