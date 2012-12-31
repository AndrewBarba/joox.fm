//
//  JXFMAppDelegate+CoreData.m
//  joox.fm
//
//  Created by Andrew Barba on 6/15/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JXFMAppDelegate+CoreData.h"

@implementation JXFMAppDelegate (CoreData)

+(UIManagedDocument *)document
{
    JXFMAppDelegate *delegate = [JXFMAppDelegate appDelegate];
    return delegate.jxfmDocument;
}

+(NSManagedObjectContext *)context
{
    return [JXFMAppDelegate document].managedObjectContext;
}

+(NSManagedObjectContext *)importContext
{
    return [JXFMAppDelegate appDelegate].importContext;
}

+(void)deleteObject:(NSManagedObject *)object
{
    NSManagedObject *deleteObject = [[JXFMAppDelegate context] objectWithID:object.objectID];
    [[JXFMAppDelegate context] performBlock:^{
        [[JXFMAppDelegate context] deleteObject:deleteObject];
    }];
}

+(void)updateContexts
{
    [[JXFMAppDelegate importContext] performBlockAndWait:^{
        [[JXFMAppDelegate importContext] save:nil];
        [[JXFMAppDelegate importContext] reset];
    }];
}

+(void)useDocument:(DoneCompletionHandler)complete
{
    [[JXFMAppDelegate appDelegate] useDocument:^{
        if (complete) complete();
    }];
}

+(void)saveDocument:(DoneCompletionHandler)complete
{
    UIManagedDocument *document = [JXFMAppDelegate document];
    [document saveToURL:document.fileURL
       forSaveOperation:UIDocumentSaveForOverwriting
      completionHandler:^(BOOL done){
          NSLog(@"Document Saved");
          if (complete) complete();
      }];
}

+(void)storeLists:(NSDictionary *)lists
{
    NSManagedObjectContext *context = [JXFMAppDelegate importContext];
    [context performBlockAndWait:^{
        if (lists.count > 0) {
            [lists enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *list, BOOL *stop){
                [JXFMAppDelegate createListFromDictionary:list inContext:context];
            }];
        }
        [self removeOldLists:lists fromContext:context];
    }];
}

+(void)storeInvites:(NSDictionary *)invites
{
    NSManagedObjectContext *context = [JXFMAppDelegate importContext];
    [context performBlockAndWait:^{
        if (invites.count > 0) {
            [invites enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *invite, BOOL *stop){
                [Invite createInviteFromDictionary:invite inContext:context];
            }];
            [JXFMAppDelegate updateContexts];
        }
        [self removeOldInvites:invites];
    }];
}

+(void)storeFacebookFriends:(NSArray *)friends
{
    [[JXFMAppDelegate importContext] performBlockAndWait:^{
        for (NSDictionary *dict in friends) {
            [User createUserFromFacebook:dict inContext:[JXFMAppDelegate importContext]];
        }
        [JXFMAppDelegate updateContexts];
    }];
}

+(void)storeFeed:(NSDictionary *)feed
{
    NSManagedObjectContext *context = [JXFMAppDelegate importContext];
    [context performBlockAndWait:^{
        if (feed.count > 0) {
            [feed enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *activity, BOOL *stop){
                [Activity activityFromDictionary:activity inContext:context];
            }];
            [JXFMAppDelegate updateContexts];
        }
    }];
}

+(void)removeOldLists:(NSDictionary *)lists fromContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        NSArray *myLists = [JooxList allListsInContext:context];
        for (JooxList *myList in myLists) {
            if (lists.count == 0 || !lists[[myList.identifier.description ID]]) {
                [context deleteObject:myList];
            }
        }
        [JXFMAppDelegate updateContexts];
    }];
}

+(void)removeOldInvites:(NSDictionary *)invites
{
    NSManagedObjectContext *context = [JXFMAppDelegate importContext];
    [context performBlockAndWait:^{
        for (Invite *invite in [Invite allInvitesInContext:context]) {
            if (invites.count == 0 || !invites[[invite.identifier.description ID]]) {
                [context deleteObject:invite];
            }
        }
        [JXFMAppDelegate updateContexts];
    }];
}

+(void)createListFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    if (dict == nil) return;
    
    [context performBlockAndWait:^{
        JooxList *list = nil;
        
        if ([dict[@"type"] isEqualToString:@"playlist"]) {
            list = [Playlist createPlaylistWithDicitonary:dict inContext:context];
        } else if ([dict[@"type"] isEqualToString:@"party"]) {
            list = [Party createPartyWithDictionary:dict inContext:context];
        }
        
        if (!list) return;
        
        if ([dict[@"users"] count] > 0) {
            [dict[@"users"] enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *userDict, BOOL *stop){
                User *user = [User createUserFromDictionary:userDict inContext:context];
                [ListUser createListUserWithUser:user inList:list fromDictionary:userDict inContext:context];
            }];
        }
        
        if ([dict[@"followers"] count] > 0) {
            [dict[@"followers"] enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *userDict, BOOL *stop){
                User *user = [User createUserFromDictionary:userDict inContext:context];
                [PlaylistFollower createListFollowerWithUser:user inList:(Playlist *)list fromDictionary:userDict inContext:context];
            }];
        }
        
        if ([dict[@"tracks"] count] > 0) {
            [dict[@"tracks"] enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *trackDict, BOOL *stop){
                Track *track = [Track createTrackWithDictionary:trackDict inContext:context];
                if ([dict[@"type"] isEqualToString:@"playlist"]) {
                    [PlaylistTrack createListTrackWithTrack:track inList:list fromDictionary:trackDict inContext:context];
                } else if ([dict[@"type"] isEqualToString:@"party"]) {
                    [PartyTrack createListTrackWithTrack:track inList:list fromDictionary:trackDict inContext:context];
                }
            }];
        }
        
        list.creator = [User getUserByFB:dict[@"host_fb"] inContext:[JXFMAppDelegate importContext]];
        [JXFMAppDelegate updateList:list toDictionary:dict inContext:context];
    }];
}

+(void)updateList:(JooxList *)list toDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    for (ListTrack *pTrack in list.tracks) {
        if ([dict[@"tracks"] count] > 0) {
            if (dict[@"tracks"][[pTrack.track.identifier.description ID]]) {
                pTrack.rating = @([dict[@"tracks"][[pTrack.track.identifier.description ID]][@"rating"] integerValue]);
            } else {
                [context deleteObject:pTrack];
            }
        } else {
            [context deleteObject:pTrack];
        }
    }
    
    for (ListUser *pUser in list.users) {
        if (dict[@"users"][[pUser.user.identifier.description ID]]) {
            NSDictionary *user = dict[@"users"][[pUser.user.identifier.description ID]];
            pUser.timestamp = [user timestamp];
        } else {
            [context deleteObject:pUser];
        }
    }
    
    if ([list class] == [Playlist class]) {
        Playlist *playlist = (Playlist *)list;
        for (PlaylistFollower *pFollower in playlist.followers) {
            if (dict[@"followers"][[pFollower.user.identifier.description ID]]) {
                NSDictionary *user = dict[@"followers"][[pFollower.user.identifier.description ID]];
                pFollower.timestamp = [user timestamp];
            } else {
                [context deleteObject:pFollower];
            }
        }
    }
    
    [JXFMAppDelegate storeFeed:dict[@"feed"]];
}

@end
