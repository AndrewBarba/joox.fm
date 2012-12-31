//
//  Track.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ListTrack;

@interface Track : NSManagedObject

@property (nonatomic, retain) NSString * artworkURL;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * isCached;
@property (nonatomic, retain) NSString * service;
@property (nonatomic, retain) NSString * src;
@property (nonatomic, retain) NSString * streamURL;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *listTracks;
@end

@interface Track (CoreDataGeneratedAccessors)

- (void)addListTracksObject:(ListTrack *)value;
- (void)removeListTracksObject:(ListTrack *)value;
- (void)addListTracks:(NSSet *)values;
- (void)removeListTracks:(NSSet *)values;

@end
