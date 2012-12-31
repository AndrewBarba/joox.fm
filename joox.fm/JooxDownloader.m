//
//  JooxDownloader.m
//  joox.fm
//
//  Created by Andrew Barba on 8/7/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxDownloader.h"

@interface JooxDownloader()
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSURL *trackURL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) YouTubeExtractor *extractor;
@property (nonatomic) double expectedBytes;
@property (nonatomic) double bytesReceived;
@end

@implementation JooxDownloader

-(void)downloadTrack:(Track *)track
{
    if (self.connection || !track) return;
    self.track = track;
    if ([track isYouTube]) {
        [self downloadYoutubeTrack];
    } else if ([track isSoundCloud]) {
        [self downloadSoundCloudTrack];
    }
    [self.delegate startedDownloading];
}

-(BOOL)isDownloading
{
    return self.connection != nil;
}

-(void)downloadYoutubeTrack
{
    self.extractor = [[YouTubeExtractor alloc] initWithTrack:self.track quality:YouTubePlayerQualityHigh andDelegate:self];
}

-(void)downloadSoundCloudTrack
{
    self.trackURL = [NSURL URLWithString:self.track.streamURL];
    [self start];
}

-(void)extractedURL:(NSURL *)url
{
    self.trackURL = url;
    [self start];
}

-(void)failedToExtractURL
{
    [self done:NO];
}

-(void)start
{
    self.filePath = [self.track getCachePath];
    [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
    self.fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.filePath];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.trackURL];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)done:(BOOL)finished
{
    [self.fileHandle closeFile];
    if (!finished) [self.connection cancel];
    if (!finished) [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    self.connection = nil;
    self.bytesReceived = 0;
    self.expectedBytes = NSURLResponseUnknownLength;
    self.fileHandle = nil;
    [self.delegate finishedDownloading:finished];
    [self.track.managedObjectContext performBlockAndWait:^{
        self.track.isCached = finished ? @(YES) : nil;
        [self.track.managedObjectContext save:nil];
    }];
    self.track = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection Failed");
    [self done:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.expectedBytes = [response expectedContentLength];
    self.bytesReceived = 0;
    [self.track.managedObjectContext performBlock:^{
        self.track.isCached = @(YES);
    }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.fileHandle) {
        [self.fileHandle seekToEndOfFile];
        [self.fileHandle writeData:data];
        
        self.bytesReceived += [data length];
        if(self.expectedBytes != NSURLResponseUnknownLength) {
            [self.delegate updatedProgress:(self.bytesReceived/self.expectedBytes)];
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Finished Loading");
    [self done:YES];
}

@end
