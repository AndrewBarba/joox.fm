//
//  Activity.h
//  joox.fm
//
//  Created by Andrew Barba on 10/30/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JooxList, ListTrack, ListUser, PlaylistFollower;

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) JooxList *list;
@property (nonatomic, retain) ListTrack *listTrack;
@property (nonatomic, retain) ListUser *listUser;
@property (nonatomic, retain) PlaylistFollower *listFollower;

@end
