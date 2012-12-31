//
//  Track+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Track.h"

@interface Track (Create)
+(Track *)createTrackWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
@end
