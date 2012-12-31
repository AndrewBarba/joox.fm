//
//  JooxDownloader.h
//  joox.fm
//
//  Created by Andrew Barba on 8/7/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouTubeExtractor.h"
#import "Track+Get.h"

@protocol JooxDownloadDelegate <NSObject>
-(void)updatedProgress:(CGFloat)progress;
-(void)finishedDownloading:(BOOL)success;
-(void)startedDownloading;
@end

@interface JooxDownloader : NSObject <NSURLConnectionDelegate,YouTubeExtractorDelegate>
@property (nonatomic, strong) id <JooxDownloadDelegate> delegate;
@property (nonatomic, strong) Track *track;
-(void)downloadTrack:(Track *)track;
-(BOOL)isDownloading;
-(void)done:(BOOL)finished;
@end
