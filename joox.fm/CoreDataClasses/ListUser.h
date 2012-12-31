//
//  ListUser.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity, JooxList, User;

@interface ListUser : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSDate * lastview;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *activity;
@property (nonatomic, retain) JooxList *list;
@property (nonatomic, retain) User *user;
@end

@interface ListUser (CoreDataGeneratedAccessors)

- (void)addActivityObject:(Activity *)value;
- (void)removeActivityObject:(Activity *)value;
- (void)addActivity:(NSSet *)values;
- (void)removeActivity:(NSSet *)values;

@end
