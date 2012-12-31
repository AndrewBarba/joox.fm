//
//  Vote.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ListTrack, User;

@interface Vote : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) ListTrack *track;
@property (nonatomic, retain) User *user;

@end
