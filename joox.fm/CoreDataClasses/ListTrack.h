//
//  ListTrack.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity, JooxList, Track, User, Vote;

@interface ListTrack : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *activity;
@property (nonatomic, retain) JooxList *list;
@property (nonatomic, retain) Track *track;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *votes;
@end

@interface ListTrack (CoreDataGeneratedAccessors)

- (void)addActivityObject:(Activity *)value;
- (void)removeActivityObject:(Activity *)value;
- (void)addActivity:(NSSet *)values;
- (void)removeActivity:(NSSet *)values;

- (void)addVotesObject:(Vote *)value;
- (void)removeVotesObject:(Vote *)value;
- (void)addVotes:(NSSet *)values;
- (void)removeVotes:(NSSet *)values;

@end
