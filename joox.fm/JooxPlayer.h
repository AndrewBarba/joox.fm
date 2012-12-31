//
//  PlayerViewController.h
//  joox.fm
//
//  Created by Andrew Barba on 7/6/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "YouTubeExtractor.h"
#import "ListTrack+Get.h"
#import "ListUser+Get.h"
#import "JooxList+Get.h"

#define JooxPlayerListTrackChangedNotification @"ListTrackChangedNotification"

@protocol JooxPlayerDelegate <NSObject>
-(void)currentTrackChanged:(Track *)track;
-(void)playerDidPause;
-(void)playerDidStartPlaying;
-(void)playerIsSeeking;
-(void)loadStateChanged:(NSInteger)state;
-(void)beganLoadingTrack;
-(void)failedToLoadTrack;
-(void)didEnterFullScreen;
-(void)willExitFullScreen;
-(void)didExitFullScreen;
@end

@interface JooxPlayer : NSObject <YouTubeExtractorDelegate, AVAudioSessionDelegate>
@property (nonatomic, weak) id <JooxPlayerDelegate> delegate;
@property (nonatomic,strong) JooxList *list;
@property (nonatomic,strong) NSArray *sortDescriptors;
@property (nonatomic, strong) ListTrack *listTrack;
@property (nonatomic, strong) Track *soloTrack;
@property (nonatomic, strong) Track *currentTrack;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) MPMoviePlayerController *player;
@property (nonatomic, strong) AVAudioSession *session;
-(void)playTrack:(ListTrack *)newTrack;
-(void)playSoloTrack:(Track *)track;
-(void)removeFromSuperView;
-(void)previousTrack;
-(void)nextTrack;
-(BOOL)isPlaying;
-(BOOL)isPaused;
-(BOOL)isStopped;
-(BOOL)isSeeking;
-(BOOL)togglePlayer;
@end
