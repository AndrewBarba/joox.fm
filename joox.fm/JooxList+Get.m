//
//  JooxList+Get.m
//  joox.fm
//
//  Created by Andrew Barba on 7/1/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxList+Get.h"
#import "User+Get.h"
#import "Joox.h"

@implementation JooxList (Get)
+(JooxList *)getListByIdentifier:(NSInteger)ID inContext:(NSManagedObjectContext *)context
{
    JooxList *list = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"JooxList"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %i",ID];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching playlists");
    } else if (matches.count == 1) {
        list = [matches lastObject];
    }
    
    return list;
}

+(NSArray *)allTracks:(JooxList *)list inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ListTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"list.type BEGINSWITH[n] %@ AND list.identifier == %@",list.type,list.identifier];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    return [context executeFetchRequest:request error:nil];
}

+(NSArray *)allListsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"JooxList"];
    return [context executeFetchRequest:request error:nil];
}

-(BOOL)isParty
{
    return [self.type isEqualToString:@"party"];
}

-(BOOL)isPlaylist
{
    return [self.type isEqualToString:@"playlist"];
}

-(BOOL)isHost
{
    return [self.creator.identifier integerValue] == [[Joox getUserInfo][@"id"] integerValue];
}

@end
