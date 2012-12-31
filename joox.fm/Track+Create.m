//
//  Track+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Track+Create.h"
#import "Track+Get.h"
#import "Joox.h"

#define SOUNDCLOUD_API_KEY @"da9b2dd18d6b46a5d2999962447c41aa"

@implementation Track (Create)

+(Track *)createTrackWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    Track *track = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Track"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@",@([dict[@"id"] integerValue])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching tracks");
    } else if (matches.count >= 1) {
        track = [matches lastObject];
    } else {
        track = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:context];
        track.identifier = @([dict[@"id"] integerValue]);
        track.service = dict[@"service"];
        track.title = [Joox strip:dict[@"title"]];
        track.src = dict[@"src"];
        track.artworkURL = dict[@"artwork"];
        track.timestamp = [NSDate date];
        track.duration = @([dict[@"duration"] integerValue]);
        track.isCached = [[NSFileManager defaultManager] fileExistsAtPath:[track getCachePath]] ? @(YES) : nil;
        if ([dict[@"service"] isEqualToString:ServiceSoundCloud]) {
            track.streamURL = [NSString stringWithFormat:@"http://api.soundcloud.com/tracks/%@/stream?&client_id=%@",dict[@"src"],SOUNDCLOUD_API_KEY];
        }
    }
    
    if (![track.title isEqualToString:dict[@"title"]]) track.title = dict[@"title"];
    
    return track;
}


@end
