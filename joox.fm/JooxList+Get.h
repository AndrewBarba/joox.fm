//
//  JooxList+Get.h
//  joox.fm
//
//  Created by Andrew Barba on 7/1/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxList.h"

@interface JooxList (Get)
+(JooxList *)getListByIdentifier:(NSInteger)ID inContext:(NSManagedObjectContext *)context;
+(NSArray *)allTracks:(JooxList *)list inContext:(NSManagedObjectContext *)context;
+(NSArray *)allListsInContext:(NSManagedObjectContext *)context;
-(BOOL)isParty;
-(BOOL)isPlaylist;
-(BOOL)isHost;
@end
