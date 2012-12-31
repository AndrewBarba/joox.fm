//
//  JXRequest.m
//  joox.fm
//
//  Created by Andrew Barba on 6/15/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JXRequest.h"
#import "JXFMAppDelegate+CoreData.h"

@implementation JXRequest

+(void)performRequestToURL:(NSURL *)url onCompletion:(JXRequestCompletionHandler)complete
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLCacheStorageAllowedInMemoryOnly
                                                            timeoutInterval:10];
    [request setAllowsCellularAccess:YES];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (complete) complete(output,error);
    }];
}

+ (void)performQueryToPage:(NSString *)page withData:(NSString *)data onCompletion:(JXRequestCompletionHandler)complete
{
    NSString *host = [NSString stringWithFormat:@"%@/%@.php?%@",API_PATH,page,data?data:@""];
    if ([Joox isUserValid]) {
        host = [host stringByAppendingFormat:@"&%@",[JXRequest getUserCredentialString]];
    }
    NSLog(@"%@",host);
    
    [JXRequest performRequestToURL:[NSURL URLWithString:host] onCompletion:complete];
}

+(void)fetchEverything:(JXRequestDoneCompletionHandler)complete
{
    NSArray *failedRequests = [FailedRequest allFailedRequests:[JXFMAppDelegate context]];
    for (FailedRequest *request in failedRequests) {
        [JXRequest performQueryToPage:request.page withData:request.data onCompletion:^(NSString *result,NSError *error){
            if (!error) {
                [[JXFMAppDelegate context] performBlock:^{
                    [[JXFMAppDelegate context] deleteObject:request];
                    NSLog(@"Resolved Failed Request");
                }];
            }
        }];
    }
    
    [JXRequest performQueryToPage:@"geteverything" withData:nil onCompletion:^(NSString *result, NSError *error){
        if (!error) {
            NSDictionary *all = [result JSON];
            NSDictionary *lists = all[@"lists"];
            NSDictionary *invties = all[@"invites"];
            [JXFMAppDelegate storeLists:lists];
            [JXFMAppDelegate storeInvites:invties];
        }
        if (complete) complete();
    }];
}

+(void)fetchJooxLists:(JXRequestDoneCompletionHandler)complete
{
    [JXRequest performQueryToPage:@"getlists" withData:nil onCompletion:^(NSString *result, NSError *e){
        if (!e) {
            NSDictionary *lists = [result JSON];
            [JXFMAppDelegate storeLists:lists];
            if (complete) complete();
        } else {
            if (complete) complete();
        }
    }];
}

+(void)fetchParty:(NSInteger)partyID onCompletion:(JXRequestDoneCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"party_id=%i",partyID];
    [JXRequest performQueryToPage:@"getparty" withData:data onCompletion:^(NSString *result,NSError *error){
        if (![result isEqualToString:@""] && result != nil) {
            NSDictionary *party = [result JSON];
            [JXFMAppDelegate createListFromDictionary:party inContext:[JXFMAppDelegate importContext]];
            [JXFMAppDelegate updateContexts];
        }
        if (complete) complete();
    }];
}

+(void)fetchPlaylist:(NSInteger)playlistID onCompletion:(JXRequestDoneCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"playlist_id=%i",playlistID];
    [JXRequest performQueryToPage:@"getplaylist" withData:data onCompletion:^(NSString *result,NSError *error){
        if (![result isEqualToString:@""] && result != nil) {
            NSDictionary *playlist = [result JSON];
            [JXFMAppDelegate createListFromDictionary:playlist inContext:[JXFMAppDelegate importContext]];
            [JXFMAppDelegate updateContexts];
        }
        if (complete) complete();
    }];
}

+(void)completeFailedRequests:(JooxList *)list
{
    for (FailedRequest *request in list.failedRequests) {
        [JXRequest performQueryToPage:request.page withData:request.data onCompletion:^(NSString *result,NSError *error){
            if (!error) {
                [[JXFMAppDelegate context] performBlock:^{
                    [[JXFMAppDelegate context] deleteObject:request];
                    NSLog(@"Resolved Failed Request");
                }];
            }
        }];
    }
}

+(void)fetchFeed:(JXRequestDictionaryCompletionHandler)complete
{
    [JXRequest performQueryToPage:@"getfeed" withData:nil onCompletion:^(NSString *result,NSError *error){
        if (result) {
            NSDictionary *feed = [result JSON];
            complete(feed);
        }
    }];
}

+(void)fetchAllParties:(JXRequestDoneCompletionHandler)complete
{
    [JXRequest performQueryToPage:@"getparties" withData:@"" onCompletion:^(NSString *result,NSError *error){
        NSDictionary *parties = ![result isEqualToString:@""] ? [result JSON] : nil;
        if (parties != nil) {
            [JXFMAppDelegate storeLists:parties];
        }
        if (complete) complete();
    }];
}

+(void)fetchAllPlaylists:(JXRequestDoneCompletionHandler)complete
{
    [JXRequest performQueryToPage:@"getplaylists" withData:@"" onCompletion:^(NSString *result,NSError *error){
        NSDictionary *playlists = ![result isEqualToString:@""] ? [result JSON] : nil;
        if (playlists != nil) {
            [JXFMAppDelegate storeLists:playlists];
        }
        if (complete) complete();
    }];
}

+(void)fetchAllInvites:(JXRequestIntegerCompletionHandler)complete
{
    [JXRequest performQueryToPage:@"getinvites" withData:@"" onCompletion:^(NSString *result,NSError *error){
        if (![result isEqualToString:@""] && result && !error) {
            NSDictionary *invites = [result JSON];
            if (invites != nil) {
                [JXFMAppDelegate storeInvites:invites];
            }
            if (complete) complete(invites.count);
        } else {
            if (complete) complete(0);
        }
    }];
}

+(void)performQueryToYouTube:(NSString *)query onCompletion:(JXRequestArrayCompletionHandler)complete
{
    query = [Joox urlEncodeString:query];
    NSString *key = @"AI39si7DVscu67xbW9-UwY0FZ1Xs5sZV9YAUeWy4PAqKD04Bj-Zh7bGJhTd5xGkP2jCMay4zUfFuTp0FIBteaShI63rUgQ0MDg";
    NSString *host = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?v=2&alt=jsonc&q=%@&max-results=50&format=6&key=%@",query,key];
    [JXRequest performRequestToURL:[NSURL URLWithString:host] onCompletion:^(NSString *result, NSError *error){
        if (error) {
            if (complete) complete(nil);
        } else {
            if (complete) complete([result JSON][@"data"][@"items"]);
        }
    }];
}

+(void)performQueryToGrooveshark:(NSString *)query onCompletion:(JXRequestArrayCompletionHandler)complete
{
    query = [Joox urlEncodeString:query];
    NSString *host = [NSString stringWithFormat:@"http://joox.fm/api/grooveshark.php?query=%@&type=search",query];
    [JXRequest performRequestToURL:[NSURL URLWithString:host] onCompletion:^(NSString *result, NSError *error){
        if (error) {
            if (complete) complete(nil);
        } else {
            if (complete) complete([result JSON]);
        }
    }];
}

+(void)getGrooveSharkStreamURL:(NSString *)src onComplete:(JXRequestStringCompletionHandler)complete
{
    NSString *host = [NSString stringWithFormat:@"http://joox.fm/api/grooveshark.php?query=%@&type=stream",src];
    [JXRequest performRequestToURL:[NSURL URLWithString:host] onCompletion:^(NSString *result, NSError *error){
        if (error) {
            if (complete) complete(nil);
        } else {
            if (complete) complete(result);
        }
    }];
}

+(void)performQueryToSoundCloud:(NSString *)query onCompletion:(JXRequestArrayCompletionHandler)complete
{
    query = [Joox urlEncodeString:query];
    NSString *host = [NSString stringWithFormat:@"http://api.soundcloud.com/tracks.json?q=%@&client_id=da9b2dd18d6b46a5d2999962447c41aa",query];
    [JXRequest performRequestToURL:[NSURL URLWithString:host] onCompletion:^(NSString *result, NSError *error){
        if (error) {
            if (complete) complete(nil);
        } else {
            if (complete) complete([result JSON]);
        }
    }];
}

+ (NSString *)getUserCredentialString
{
    NSDictionary *userInfo = [Joox getUserInfo];
    NSString *fb = userInfo[@"fb"];
    NSString *secret = userInfo[@"secret"];
    return [NSString stringWithFormat:@"fb=%@&secret=%@",fb,secret];
}

+(void)addUserWithToken:(NSString *)token onCompletion:(JXRequestDictionaryCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"token=%@",token];
    [JXRequest performQueryToPage:@"adduser" withData:data onCompletion:^(NSString *result,NSError *error){
        if (!error) {
            NSDictionary *userDict = [result JSON];
            if (complete) complete(userDict);
        } else {
            if (complete) complete(nil);
        }
    }];
}

+(void)updatePushToken:(NSData *)deviceToken
{
    if (![Joox isUserValid]) return;
    NSString *data = [NSString stringWithFormat:@"push_token=%@",deviceToken];
    data = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [JXRequest performQueryToPage:@"adduser" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            NSLog(@"Push token updated successfully");
        } else {
            NSLog(@"Failed to update push token");
        }
    }];
}

+(void)createPlaylist:(NSString *)name onCompletion:(JXRequestIntegerCompletionHandler)complete
{
    name = [Joox urlEncodeString:name];
    NSString *data = [NSString stringWithFormat:@"name=%@",name];
    [JXRequest performQueryToPage:@"addplaylist" withData:data onCompletion:^(NSString *result,NSError *error){
        if (!error && result && ![result isEqualToString:@""]) {
            if (complete) complete([result integerValue]);
        } else {
            if (complete) complete(0);
        }
    }];
}

+(void)createParty:(NSString *)name fromPlaylist:(NSInteger)playlistID onCompletion:(JXRequestStringCompletionHandler)complete
{
    name = [Joox urlEncodeString:name];
    NSString *data = [NSString stringWithFormat:@"name=%@",name];
    if (playlistID >= 0) data = [data stringByAppendingFormat:@"&playlist_id=%i",playlistID];
    [JXRequest performQueryToPage:@"addparty" withData:data onCompletion:^(NSString *result,NSError *error){
        if (!error && result && ![result isEqualToString:@""]) {
            if (complete) complete(result);
        } else {
            if (complete) complete(nil);
        }
    }];
}

+(void)joinPartyWithJooxID:(NSString *)jooxID onCompletion:(JXRequestIntegerCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"joox_id=%@",jooxID];
    [JXRequest performQueryToPage:@"join" withData:data onCompletion:^(NSString *result,NSError *error){
        if (result && ![result isEqualToString:@""]) {
            if (complete) complete([result integerValue]);
        } else {
            if (complete) complete(0);
        }
    }];
}

+(void)addTrack:(NSDictionary *)track toParty:(NSInteger)partyID withService:(NSString *)service onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *src = nil;
    if ([service isEqualToString:ServiceGrooveShark]) {
        src = track[@"SongID"];
    } else {
        src   = [Joox sourceFromTrack:track];
    }
    
    NSString *data = [NSString stringWithFormat:@"track_src=%@&@&service=%@&party_id=%i",src,service,partyID];
    
    [JXRequest performQueryToPage:@"addtrack" withData:data onCompletion:^(NSString *result,NSError *error) {
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"addtrack" withData:data andListID:partyID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)addTrack:(NSDictionary *)track toPlaylist:(NSInteger)playlistID withService:(NSString *)service onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *src = nil;
    if ([service isEqualToString:ServiceGrooveShark]) {
        src = track[@"SongID"];
    } else {
        src   = [Joox sourceFromTrack:track];
    }
    
    NSString *data = [NSString stringWithFormat:@"track_src=%@&service=%@&playlist_id=%i",src,service,playlistID];
    
    [JXRequest performQueryToPage:@"addtrack" withData:data onCompletion:^(NSString *result,NSError *error) {
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"addtrack" withData:data andListID:playlistID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)addTrack:(Track *)track toParty:(JooxList *)party onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"track_id=%@&party_id=%@",track.identifier,party.identifier];
    [JXRequest performQueryToPage:@"addtrack" withData:data onCompletion:^(NSString *result, NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"addtrack" withData:data andListID:[party.identifier integerValue] inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)addTrack:(Track *)track toPlaylist:(JooxList *)playlist onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"track_id=%@&playlist_id=%@",track.identifier,playlist.identifier];
    [JXRequest performQueryToPage:@"addtrack" withData:data onCompletion:^(NSString *result, NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"addtrack" withData:data andListID:[playlist.identifier integerValue] inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)voteTrack:(NSInteger)trackID forParty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"track_id=%i&party_id=%i",trackID,partyID];
    [JXRequest performQueryToPage:@"vote" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"vote" withData:data andListID:partyID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)voteTrack:(NSInteger)trackID forPlaylist:(NSInteger)playlistID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"track_id=%i&playlist_id=%i",trackID,playlistID];
    [JXRequest performQueryToPage:@"vote" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"vote" withData:data andListID:playlistID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)removeTrack:(NSInteger)trackID fromParty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"track_id=%i&party_id=%i",trackID,partyID];
    [JXRequest performQueryToPage:@"removetrack" withData:data onCompletion:^(NSString *result,NSError *error){
        if (complete) complete([result isEqualToString:@"YES"]);
    }];
}

+(void)removeTrack:(NSInteger)trackID fromPlaylist:(NSInteger)playlistID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"track_id=%i&playlist_id=%i",trackID,playlistID];
    [JXRequest performQueryToPage:@"removetrack" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"removetrack" withData:data andListID:playlistID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)removeUserFromParty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"party_id=%i",partyID];
    [JXRequest performQueryToPage:@"removeuser" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"removeuser" withData:data andListID:partyID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)removeUserFromPlaylist:(NSInteger)playlistID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"playlist_id=%i",playlistID];
    [JXRequest performQueryToPage:@"removeuser" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"removeuser" withData:data andListID:playlistID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)unfollowPlaylist:(NSInteger)playlistID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"playlist_id=%i",playlistID];
    [JXRequest performQueryToPage:@"unfollow" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"unfollow" withData:data andListID:playlistID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)endparty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"party_id=%i",partyID];
    [JXRequest performQueryToPage:@"endparty" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"endparty" withData:data andListID:partyID inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)restartParty:(NSInteger)partyID onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"party_id=%i",partyID];
    [JXRequest performQueryToPage:@"restartparty" withData:data onCompletion:^(NSString *result, NSError *e){
        if (complete) complete(!e && ![result isEqualToString:@"NO"]);
    }];
}

+(void)acceptInvite:(Invite *)invite onCompletion:(JXRequestStringCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"accept=yes&invite_id=%@",invite.identifier];
    [JXRequest performQueryToPage:@"accept" withData:data onCompletion:^(NSString *result,NSError *error){
        if (result && ![result isEqualToString:@""]) {
            if (complete) complete(result);
        } else {
            if (complete) complete(nil);
        }
    }];
}

+(void)declineInvite:(Invite *)invite onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"accept=no&invite_id=%@",invite.identifier];
    [JXRequest performQueryToPage:@"accept" withData:data onCompletion:^(NSString *result,NSError *error){
        if ([result isEqualToString:@"YES"]) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
            if (!complete && error) {
                [FailedRequest createRequestToPage:@"accept" withData:data andListID:0 inContext:[JXFMAppDelegate context]];
                [JXFMAppDelegate saveDocument:nil];
            }
        }
    }];
}

+(void)inviteUser:(User *)user toPlaylist:(NSInteger)ID onCompletion:(JXRequestIntegerCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"playlist_id=%i&user_fb=%@&fb_name=%@",ID,user.fb,user.fbName];
    [JXRequest performQueryToPage:@"invite" withData:data onCompletion:^(NSString *result,NSError *error){
        NSUInteger success = JXRequestInviteFailure;
        if ([result isEqualToString:@"YES"]) {
            success = JXRequestInviteSuccess;
        } else if ([result isEqualToString:@"NO"]) {
            success = JXRequestInviteSuccessNoAccount;
        }
        
        if (complete) complete(success);
    }];
}

+(void)subscribeToEmailNotifications:(BOOL)notifications onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"notifications=%@",notifications?@"YES":@"NO"];
    [JXRequest performQueryToPage:@"subscribe" withData:data onCompletion:^(NSString *result, NSError *error){
        if (complete) complete(!error && [result isEqualToString:@"YES"]);
    }];
}

+(void)subscribeToEmailUpdates:(BOOL)subscribe onCompletion:(JXRequestSuccessCompletionHandler)complete
{
    NSString *data = [NSString stringWithFormat:@"updates=%@",subscribe?@"YES":@"NO"];
    [JXRequest performQueryToPage:@"subscribe" withData:data onCompletion:^(NSString *result, NSError *error){
        if (complete) complete(!error && [result isEqualToString:@"YES"]);
    }];
}

+(void)playTrack:(NSInteger)trackID inParty:(NSInteger)partyID
{
    NSString *data = [NSString stringWithFormat:@"party_id=%i&track_id=%i",partyID,trackID];
    [JXRequest performQueryToPage:@"updatetrack" withData:data onCompletion:nil];
}

@end
