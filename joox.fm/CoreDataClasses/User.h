//
//  User.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JooxList, ListTrack, ListUser, Vote;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * fb;
@property (nonatomic, retain) NSString * fbName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * isFriend;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *addedTracks;
@property (nonatomic, retain) NSSet *createdLists;
@property (nonatomic, retain) NSSet *lists;
@property (nonatomic, retain) NSSet *votes;
@property (nonatomic, retain) NSManagedObject *followedLists;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAddedTracksObject:(ListTrack *)value;
- (void)removeAddedTracksObject:(ListTrack *)value;
- (void)addAddedTracks:(NSSet *)values;
- (void)removeAddedTracks:(NSSet *)values;

- (void)addCreatedListsObject:(JooxList *)value;
- (void)removeCreatedListsObject:(JooxList *)value;
- (void)addCreatedLists:(NSSet *)values;
- (void)removeCreatedLists:(NSSet *)values;

- (void)addListsObject:(ListUser *)value;
- (void)removeListsObject:(ListUser *)value;
- (void)addLists:(NSSet *)values;
- (void)removeLists:(NSSet *)values;

- (void)addVotesObject:(Vote *)value;
- (void)removeVotesObject:(Vote *)value;
- (void)addVotes:(NSSet *)values;
- (void)removeVotes:(NSSet *)values;

@end
