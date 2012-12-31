//
//  JooxList.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity, FailedRequest, ListTrack, ListUser, User;

@interface JooxList : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * lastView;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSSet *activity;
@property (nonatomic, retain) User *creator;
@property (nonatomic, retain) NSSet *failedRequests;
@property (nonatomic, retain) NSSet *tracks;
@property (nonatomic, retain) NSSet *users;
@end

@interface JooxList (CoreDataGeneratedAccessors)

- (void)addActivityObject:(Activity *)value;
- (void)removeActivityObject:(Activity *)value;
- (void)addActivity:(NSSet *)values;
- (void)removeActivity:(NSSet *)values;

- (void)addFailedRequestsObject:(FailedRequest *)value;
- (void)removeFailedRequestsObject:(FailedRequest *)value;
- (void)addFailedRequests:(NSSet *)values;
- (void)removeFailedRequests:(NSSet *)values;

- (void)addTracksObject:(ListTrack *)value;
- (void)removeTracksObject:(ListTrack *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;

- (void)addUsersObject:(ListUser *)value;
- (void)removeUsersObject:(ListUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
