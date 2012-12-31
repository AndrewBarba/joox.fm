//
//  Activity+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 7/1/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Activity.h"
#import "Track+Create.h"

@interface Activity (Create)
+(Activity *)activityFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+(Activity *)userActivityFromDicitonary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+(Activity *)trackActivityFromDicitonary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
@end
