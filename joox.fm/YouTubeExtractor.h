//
//  Cleaned Up version of LBYouTubePlayerViewController by Marco Muccinelli
//
//  Modified by Andrew Barba on July 6, 2012
//  Created by Marco Muccinelli on June 11, 2012.
//
//  Copyright (c) 2012 All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"

extern NSString* const YouTubeExtractorErrorDomain;
extern NSInteger const YouTubeExtractorErrorInvalidHTML;
extern NSInteger const YouTubeExtractorErrorNoStreamURL;
extern NSInteger const YouTubeExtractorErrorNoJSONData;

typedef enum {
    YouTubePlayerQualityLow  = 0,
    YouTubePlayerQualityHigh = 2,
} YouTubePlayerQuality;

@protocol YouTubeExtractorDelegate <NSObject>
-(void)extractedURL:(NSURL *)url;
-(void)failedToExtractURL;
@end

@interface YouTubeExtractor : NSObject
-(YouTubeExtractor *)initWithTrack:(Track *)track
                           quality:(NSUInteger)videoQuality
                       andDelegate:(id)urlDelegate;

@end
