//
//  JXFMFetcher.m
//  joox.fm
//
//  Created by Andrew Barba on 6/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JXFMFetcher.h"
#import "JXFMAppDelegate+CoreData.h"
#import "JXRequest.h"

@interface JXFMFetcher()
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation JXFMFetcher

-(JXFMFetcher *)initWithList:(JooxList *)list
{
    self = [super init];
    if (self) {
        if ([list.type isEqualToString:@"playlist"]) {
            self.playlistID = [list.identifier integerValue];
        } else if ([list.type isEqualToString:@"party"]) {
            self.partyID = [list.identifier integerValue];
        }
    }
    return self;
}

-(JXFMFetcher *)initWithPlaylistID:(NSNumber *)playlistID
{
    self = [super init];
    if (self) {
        self.playlistID = [playlistID integerValue];
        //[self start];
    }
    return self;
}

-(JXFMFetcher *)initWithPartyID:(NSNumber *)partyID
{
    self = [super init];
    if (self) {
        self.partyID = [partyID integerValue];
        //[self start];
    }
    return self;
}

-(void)start
{
    if (self.connection) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stop];
        self.data = [[NSMutableData alloc] init];
        if (self.partyID) {
            [self fetchParty];
        } else if (self.playlistID) {
            [self fetchPlaylist];
        }
    });
}

-(void)stop
{
    [self.connection cancel];
    self.connection = nil;
}

-(void)fetchParty
{
    NSString *host = [NSString stringWithFormat:@"http://joox.fm/api/getparty.php?party_id=%i&push=1",self.partyID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:host]
                                                                cachePolicy:NSURLCacheStorageAllowed
                                                            timeoutInterval:NSTimeIntervalSince1970];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@",host);
}

-(void)fetchPlaylist
{
    NSString *host = [NSString stringWithFormat:@"http://joox.fm/api/getplaylist.php?playlist_id=%i&push=1",self.playlistID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:host]
                                                                cachePolicy:NSURLCacheStorageAllowed
                                                            timeoutInterval:NSTimeIntervalSince1970];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@",host);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Push Connection Failed, restarting in 2 seconds");
    self.connection = nil;
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!self.connection) [self start];
    });
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self stop];
    NSLog(@"Fetched List");
    NSString *json = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    NSDictionary *list = [json JSON];
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    dispatch_async(queue, ^{
        [JXFMAppDelegate createListFromDictionary:list inContext:[JXFMAppDelegate importContext]];
        [JXFMAppDelegate updateContexts];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.data = nil;
            [self start];
        });
    });
}

@end
