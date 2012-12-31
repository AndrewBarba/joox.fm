//
//  PlaylistTrack+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "PlaylistTrack.h"

@interface PlaylistTrack (Create)
+(void)createListTrackWithTrack:(Track *)track inList:(JooxList *)list fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+(void)addTrack:(Track *)track toList:(JooxList *)list byUser:(NSString *)fb inContext:(NSManagedObjectContext *)context;
@end
