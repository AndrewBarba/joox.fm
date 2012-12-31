//
//  JXFMAppDelegate+CoreData.h
//  joox.fm
//
//  Created by Andrew Barba on 6/15/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JXFMAppDelegate.h"
#import "Playlist+Create.h"
#import "Party+Create.h"
#import "User+Create.h"
#import "Track+Create.h"
#import "PlaylistTrack+Create.h"
#import "PartyTrack+Create.h"
#import "NSDictionary+JXFM.h"
#import "Playlist+Get.h"
#import "User+Get.h"
#import "Party+Get.h"
#import "Track+Get.h"
#import "Invite+Create.h"
#import "NSString+ID.h"
#import "Activity+Create.h"
#import "JooxList+Get.h"
#import "ListTrack+Get.h"
#import "ListUser+Create.h"
#import "ListUser+Get.h"
#import "Vote+Create.h"
#import "FailedRequest+Create.h"
#import "UIImageView+WebCache.h"
#import "PlaylistFollower+Create.h"

#define ListTypeParty @"party"
#define ListTypePlaylist @"playlist"

@interface JXFMAppDelegate (CoreData)
+(UIManagedDocument *)document;
+(NSManagedObjectContext *)context;
+(NSManagedObjectContext *)importContext;
+(void)useDocument:(DoneCompletionHandler)complete;
+(void)saveDocument:(DoneCompletionHandler)complete;
+(void)storeLists:(NSDictionary *)lists;
+(void)storeInvites:(NSDictionary *)invites;
+(void)storeFacebookFriends:(NSArray *)friends;
+(void)updateContexts;
+(void)deleteObject:(NSManagedObject *)object;
+(void)createListFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
@end
