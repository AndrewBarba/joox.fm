//
//  Track+Get.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Track+Get.h"

@implementation Track (Get)
+(Track *)getTrackByIdentifier:(NSInteger)ID inContext:(NSManagedObjectContext *)context
{
    Track *track = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Track"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %i",ID];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching tracks");
    } else if (matches.count == 1) {
        track = [matches lastObject];
    }
    
    return track;
}

-(BOOL)isYouTube
{
    return [self.service isEqualToString:@"youtube"];
}

-(BOOL)isSoundCloud
{
    return [self.service isEqualToString:@"soundcloud"];
}

-(BOOL)isGrooveShark
{
    return [self.service isEqualToString:@"grooveshark"];
}

-(void)deleteCache
{
    if (self.isCached) {
        [[NSFileManager defaultManager] removeItemAtPath:[self getCachePath] error:nil];
        [self.managedObjectContext performBlock:^{
            self.isCached = nil;
        }];
    }
}

-(NSString *)getCachePath
{
    NSString *fileName = nil;
    if ([self isYouTube]) {
        fileName = [NSString stringWithFormat:@"track_yt_%@.mp4",self.identifier];
    } else if ([self isSoundCloud]) {
        fileName = [NSString stringWithFormat:@"track_sc_%@.mp3",self.identifier];
    } else if ([self isGrooveShark]) {
        fileName = [NSString stringWithFormat:@"track_gs_%@.mp3",self.identifier];
    }
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
}

-(NSString *)durationString
{
    NSInteger min = [self.duration integerValue] / 60;
    NSInteger sec = [self.duration integerValue] % 60;
    return [NSString stringWithFormat:@"%i:%02i",min,sec];
}

-(NSString *)serviceString
{
    if ([self.service isEqualToString:@"youtube"]) {
        return @"YouTube";
    } else if ([self.service isEqualToString:@"soundcloud"]) {
        return @"SoundCloud";
    }
    
    return @"";
}

@end
