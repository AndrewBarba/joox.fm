//
//  Playlist.h
//  joox.fm
//
//  Created by Andrew Barba on 10/30/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JooxList.h"

@class PlaylistFollower;

@interface Playlist : JooxList

@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSSet *followers;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addFollowersObject:(PlaylistFollower *)value;
- (void)removeFollowersObject:(PlaylistFollower *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

@end
