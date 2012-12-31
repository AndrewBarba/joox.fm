//
//  Vote+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 7/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Vote.h"
#import "ListTrack+Create.h"

@interface Vote (Create)
+(Vote *)createVoteForTrack:(ListTrack *)listTrack fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+(void)createVoteForTrack:(ListTrack *)track andUser:(NSString *)fb inContext:(NSManagedObjectContext *)context;
@end
