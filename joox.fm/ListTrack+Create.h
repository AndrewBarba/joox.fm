//
//  ListTrack+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 7/11/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ListTrack.h"
#import "JooxList+Get.h"

@interface ListTrack (Create)
-(void)initWithList:(JooxList *)list andUserID:(NSInteger)userID andTrack:(Track *)track inContext:(NSManagedObjectContext *)context;
+(void)addTrack:(NSDictionary *)track toList:(JooxList *)list inContext:(NSManagedObjectContext *)context;
-(void)updateTrack:(NSDictionary *)track inContext:(NSManagedObjectContext *)context;
//+(void)addTrack:(Track *)track toList:(JooxList *)list byUser:(NSString *)fb inContext:(NSManagedObjectContext *)context;
@end
