//
//  PlaylistFollower.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist, User;

@interface PlaylistFollower : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Playlist *playlist;
@property (nonatomic, retain) User *user;

@end
