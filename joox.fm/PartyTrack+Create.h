//
//  PartyTrack+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "PartyTrack.h"

@interface PartyTrack (Create)
+(void)createListTrackWithTrack:(Track *)track inList:(JooxList *)list fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
@end
