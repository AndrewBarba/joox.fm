//
//  JXRequest.h
//  joox.fm
//
//  Created by Andrew Barba on 6/15/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"
#import "NSString+JSON.h"
#import "Joox.h"
#import "Invite+Create.h"
#import "JooxList+Get.h"
#import "Track+Create.h"

typedef void(^JXRequestDoneCompletionHandler)(void);
typedef void(^JXRequestSuccessCompletionHandler)(BOOL);
typedef void(^JXRequestIntegerCompletionHandler)(NSUInteger);
typedef void(^JXRequestArrayCompletionHandler)(NSMutableArray*);
typedef void(^JXRequestDictionaryCompletionHandler)(NSDictionary*);
typedef void(^JXRequestStringCompletionHandler)(NSString*);
typedef void(^JXRequestCompletionHandler)(NSString*,NSError*);

#define API_PATH @"http://joox.fm/api"

#define JXRequestInviteFailure 0
#define JXRequestInviteSuccess 1
#define JXRequestInviteSuccessNoAccount 2

@interface JXRequest : NSObject
+ (NSString *)getUserCredentialString;

// BLOCK BASED METHODS
+(void)fetchEverything:(JXRequestDoneCompletionHandler)complete;
+(void)fetchJooxLists:(JXRequestDoneCompletionHandler)complete;
+(void)fetchAllParties:(JXRequestDoneCompletionHandler)complete;
+(void)fetchAllPlaylists:(JXRequestDoneCompletionHandler)complete;
+(void)fetchPlaylist:(NSInteger)playlistID onCompletion:(JXRequestDoneCompletionHandler)complete;
+(void)fetchParty:(NSInteger)partyID onCompletion:(JXRequestDoneCompletionHandler)complete;
+(void)fetchAllInvites:(JXRequestIntegerCompletionHandler)complete;
+(void)completeFailedRequests:(JooxList *)list;

+(void)performRequestToURL:(NSURL *)url onCompletion:(JXRequestCompletionHandler)complete;
+(void)performQueryToYouTube:(NSString *)query onCompletion:(JXRequestArrayCompletionHandler)complete;
+(void)performQueryToSoundCloud:(NSString *)query onCompletion:(JXRequestArrayCompletionHandler)complete;
+(void)performQueryToGrooveshark:(NSString *)query onCompletion:(JXRequestArrayCompletionHandler)complete;

+(void)addUserWithToken:(NSString*)token onCompletion:(JXRequestDictionaryCompletionHandler)complete;
+(void)updatePushToken:(NSData *)deviceToken;
+(void)createPlaylist:(NSString *)name onCompletion:(JXRequestIntegerCompletionHandler)complete;
+(void)createParty:(NSString *)name fromPlaylist:(NSInteger)playlistID onCompletion:(JXRequestStringCompletionHandler)complete;
+(void)joinPartyWithJooxID:(NSString *)jooxID onCompletion:(JXRequestIntegerCompletionHandler)complete;

+(void)addTrack:(NSDictionary *)track toPlaylist:(NSInteger)playlistID withService:(NSString *)service onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)addTrack:(NSDictionary *)track toParty:(NSInteger)partyID withService:(NSString *)service onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)addTrack:(Track *)track toPlaylist:(JooxList*)playlist onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)addTrack:(Track *)track toParty:(JooxList*)party onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)voteTrack:(NSInteger)trackID forParty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)voteTrack:(NSInteger)trackID forPlaylist:(NSInteger)playlistID onCompletion:(JXRequestSuccessCompletionHandler)complete;

+(void)removeTrack:(NSInteger)trackID fromPlaylist:(NSInteger)playlistID onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)removeTrack:(NSInteger)trackID fromParty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)removeUserFromParty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)removeUserFromPlaylist:(NSInteger)playlistID onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)unfollowPlaylist:(NSInteger)playlistID onCompletion:(JXRequestSuccessCompletionHandler)complete;

+(void)acceptInvite:(Invite *)invite onCompletion:(JXRequestStringCompletionHandler)complete;
+(void)declineInvite:(Invite *)invite onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)inviteUser:(User *)user toPlaylist:(NSInteger)ID onCompletion:(JXRequestIntegerCompletionHandler)complete;

+(void)subscribeToEmailUpdates:(BOOL)subscribe onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)subscribeToEmailNotifications:(BOOL)notifications onCompletion:(JXRequestSuccessCompletionHandler)complete;

+(void)endparty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete;
+(void)restartParty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete;

+(void)playTrack:(NSInteger)trackID inParty:(NSInteger)partyID;
@end
