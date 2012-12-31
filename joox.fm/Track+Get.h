//
//  Track+Get.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Track.h"

@interface Track (Get)
+(Track *)getTrackByIdentifier:(NSInteger)ID inContext:(NSManagedObjectContext *)context;
-(BOOL)isYouTube;
-(BOOL)isSoundCloud;
-(void)deleteCache;
-(NSString *)getCachePath;
-(NSString *)durationString;
-(NSString *)serviceString;
@end
