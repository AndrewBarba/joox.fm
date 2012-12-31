//
//  Cleaned Up version of LBYouTubePlayerViewController by Marco Muccinelli
//
//  Modified by Andrew Barba on July 6, 2012
//  Created by Marco Muccinelli on 11/06/12.
//
//  Copyright (c) 2012 All rights reserved.
//

#import "YouTubeExtractor.h"
#import "NSString+JSON.h"

static NSString* const kUserAgent =
@"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25";

NSString* const YouTubeExtractorErrorDomain      = @"YouTubeExtractorErrorDomain";
NSInteger const YouTubeExtractorErrorInvalidHTML = 1;
NSInteger const YouTubeExtractorErrorNoStreamURL = 2;
NSInteger const YouTubeExtractorErrorNoJSONData  = 3;

@interface YouTubeExtractor ()
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* buffer;
@property (nonatomic, strong) NSURL* youTubeURL;
@property (nonatomic, strong) NSURL *extractedURL;
@property (nonatomic) YouTubePlayerQuality quality;
@property (nonatomic, strong) Track *track;
@property (nonatomic, weak) id <YouTubeExtractorDelegate> delegate;
@end

@implementation YouTubeExtractor
-(YouTubeExtractor *)initWithTrack:(Track *)track quality:(NSUInteger)videoQuality andDelegate:(id)urlDelegate
{
    self = [super init];
    if (self) {
        self.delegate = urlDelegate;
        self.quality  = videoQuality;
        self.track = track;
        self.youTubeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",track.src]];
        [self startConnection];
    }
    return self;
}

-(void)closeConnection {
    [self.connection cancel];
    self.connection = nil;
    self.buffer = nil;
}

-(void)startConnection {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.youTubeURL];
    [request setValue:(NSString *)kUserAgent forHTTPHeaderField:@"User-Agent"];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.connection start];
}

// Modified answer from StackOverflow http://stackoverflow.com/questions/2099349/using-objective-c-cocoa-to-unescape-unicode-characters-ie-u1234
-(NSString *)unescapeString:(NSString *)string {
    // will cause trouble if you have "abc\\\\uvw"
    // \u   --->    \U
    NSString *esc1 = [string stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    
    // "    --->    \"
    NSString *esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    // \\"  --->    \"
    NSString *esc3 = [esc2 stringByReplacingOccurrencesOfString:@"\\\\\"" withString:@"\\\""];
    
    NSString *quoted = [[@"\"" stringByAppendingString:esc3] stringByAppendingString:@"\""];
    NSData *data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
    
    //  NSPropertyListFormat format = 0;
    //  NSString *errorDescr = nil;
    NSString *unesc = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    
    if ([unesc isKindOfClass:[NSString class]]) {
        // \U   --->    \u
        return [unesc stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
    }
    
    return nil;
}

-(NSURL*)extractYouTubeURLFromFile:(NSString *)html error:(NSError *__autoreleasing *)error {
    NSString *JSONStart = nil;
    NSString *JSONStartFull = @"ls.setItem('PIGGYBACK_DATA', \")]}'";
    NSString *JSONStartShrunk = [JSONStartFull stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([html rangeOfString:JSONStartFull].location != NSNotFound) {
        JSONStart = JSONStartFull;
    } else if ([html rangeOfString:JSONStartShrunk].location != NSNotFound) {
        JSONStart = JSONStartShrunk;
    }
    
    if (JSONStart != nil) {
        NSScanner* scanner = [NSScanner scannerWithString:html];
        [scanner scanUpToString:JSONStart intoString:nil];
        [scanner scanString:JSONStart intoString:nil];
        
        NSString *json = nil;
        [scanner scanUpToString:@"\");" intoString:&json];
        json = [self unescapeString:json];
        NSDictionary* JSONCode = [json JSON];
        
        if (!JSONCode) {
            return nil;
        } else {
            // Success
            NSArray* videos = [[[JSONCode objectForKey:@"content"] objectForKey:@"video"] objectForKey:@"fmt_stream_map"];
            NSString* streamURL = nil;
            if (videos.count) {
                NSString* streamURLKey = @"url";
                if (self.quality == YouTubePlayerQualityHigh) {
                    streamURL = [[videos objectAtIndex:0] objectForKey:streamURLKey];
                } else {
                    streamURL = [[videos lastObject] objectForKey:streamURLKey];
                }
            }
            
            if (streamURL) {
//                disable saving streamURL, aparently only good for a couple hours
//                [[JXFMAppDelegate context] performBlockAndWait:^{
//                    self.track.streamURL = streamURL;
//                    [JXFMAppDelegate saveDocument:nil];
//                }];
                return [NSURL URLWithString:streamURL];
            } else {
                if (error) *error = [NSError errorWithDomain:YouTubeExtractorErrorDomain code:2 userInfo:[NSDictionary dictionaryWithObject:@"Couldn't find the stream URL." forKey:NSLocalizedDescriptionKey]];
            }
        }
    } else {
        if (error) *error = [NSError errorWithDomain:YouTubeExtractorErrorDomain code:3 userInfo:[NSDictionary dictionaryWithObject:@"The JSON data could not be found." forKey:NSLocalizedDescriptionKey]];
    }
    
    return nil;
}

-(void)loadYouTubeURL:(NSURL *)URL {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.connection start];
}

-(void)didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    [self.delegate extractedURL:videoURL];
}

-(void)failedExtractingYouTubeURLWithError:(NSError *)error {
    NSLog(@"%@",error);
    [self.delegate failedToExtractURL];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSInteger capacity = response.expectedContentLength;
    if (capacity < 0) capacity = 0;
    self.buffer = [[NSMutableData alloc] initWithCapacity:capacity];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.buffer appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *) connection {        
    NSString* html = [[NSString alloc] initWithData:self.buffer encoding:NSUTF8StringEncoding];
    [self closeConnection];
    
    if (html.length <= 0) {
        [self failedExtractingYouTubeURLWithError:[NSError errorWithDomain:YouTubeExtractorErrorDomain code:1 userInfo:[NSDictionary dictionaryWithObject:@"Couldn't download the HTML source code. URL might be invalid." forKey:NSLocalizedDescriptionKey]]];
        return;
    }
    
    NSError* error = nil;
    self.extractedURL = [self extractYouTubeURLFromFile:html error:&error];
    if (error) {
        [self failedExtractingYouTubeURLWithError:error];
    }
    else {
        [self didSuccessfullyExtractYouTubeURL:self.extractedURL];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {      
    [self closeConnection];
    [self failedExtractingYouTubeURLWithError:error];
}

@end
