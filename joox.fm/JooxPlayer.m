//
//  PlayerViewController.m
//  joox.fm
//
//  Created by Andrew Barba on 7/6/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIImageView+WebCache.h"
#import "Track+Get.h"
#import "JooxList+Get.h"
#import "Playlist+Get.h"
#import "JXFMAppDelegate+CoreData.h"

@interface JooxPlayer ()
@property (nonatomic, strong) YouTubeExtractor *extractor;
@property (nonatomic) BOOL shouldPlay;
@end

@implementation JooxPlayer

-(id)init
{
    self = [super init];
    if (self) {
        self.player = [[MPMoviePlayerController alloc] init];
        [self.player setFullscreen:NO];
        [self.player setControlStyle:MPMovieControlStyleNone];
        [self.player setMovieSourceType:MPMovieSourceTypeFile];
        [self.player setAllowsAirPlay:NO];
        [self.player setScalingMode:MPMovieScalingModeAspectFill];
        [self.player setShouldAutoplay:YES];
        self.session = [AVAudioSession sharedInstance];
        [self initNotifications];
    }
    return self;
}

-(void)initNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFullscreen:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitFullscreen:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification object:self.player];
}

-(void)setCurrentTrack:(Track *)currentTrack
{
    if (_currentTrack != currentTrack) {
        _currentTrack = currentTrack;
        [self.delegate currentTrackChanged:currentTrack];
    }
}

-(void)setListTrack:(ListTrack *)listTrack
{
    if (_listTrack != listTrack) {
        _listTrack = listTrack;
        [[NSNotificationCenter defaultCenter] postNotificationName:JooxPlayerListTrackChangedNotification object:self];
    }
}

-(void)setSession:(AVAudioSession *)session
{
    if (_session != session) {
        _session = session;
        [_session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sessionInteruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:_session];
    }
}

-(void)sessionInteruption:(NSNotification *)notification
{
    NSUInteger type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"Interuption Began");
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"Interuption Ended");
        [self.session setActive:YES error:nil];
    }
}

-(void)loadStateChanged:(NSNotification *)notification
{
    NSLog(@"Load State Changed: %i",self.player.loadState);
    [self.delegate loadStateChanged:self.player.loadState];
}

-(void)playbackStateChanged:(NSNotification *)notification
{
    if ([self isPaused] || [self isStopped]) {
        [self.delegate playerDidPause];
    } else if ([self isPlaying]) {
        [self.delegate playerDidStartPlaying];
    } else if ([self isSeeking]) {
        [self.delegate playerIsSeeking];
    } else if (self.player.playbackState == MPMoviePlaybackStateInterrupted) {
        // Handle Interuption
    }
}

-(void)playbackFinished:(NSNotification *)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue])
	{
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            NSLog(@"Reached end of song, playing next track");
            [self nextTrack];
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"Error Playing Song");
            if ([JXFMAppDelegate appDelegate].isActive) {
                [self.delegate failedToLoadTrack];
            } else {
                [self nextTrack];
            }
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
            NSLog(@"User Stopped Playback");
			break;
            
		default:
			break;
	}
}

-(void)willExitFullscreen:(NSNotification *)notification
{
    [self.delegate willExitFullScreen];
    self.shouldPlay = [self isPlaying];
}

-(void)didExitFullscreen:(NSNotification *)notification
{
    if (self.shouldPlay) [self.player play];
    [self.delegate didExitFullScreen];
}

-(void)didEnterFullscreen:(NSNotification *)notification
{
    [self.delegate didEnterFullScreen];
}

-(void)playSoloTrack:(Track *)track
{
    self.list = nil;
    self.listTrack = nil;
    self.soloTrack = track;
    self.currentTrack = track;
    
    if (self.soloTrack.isCached) {
        [self initWithURL:[NSURL fileURLWithPath:[self.soloTrack getCachePath]]];
    } else if ([self.soloTrack.service isEqualToString:@"youtube"]) {
        [self setupYouTubeTrack:self.soloTrack];
    } else if ([self.soloTrack.service isEqualToString:@"soundcloud"]) {
        [self setupSoundCloudTrack:self.soloTrack];
    }
    
    [self setMediaInfo:track withListName:@"Downloads"];
}

-(void)playTrack:(ListTrack *)newTrack
{
    if (self.listTrack == newTrack) {
        if (![self isPlaying]) [self.player play];
        return;
    }
    
    
    
    [self.player pause];
    
    self.listTrack = newTrack;
    self.list  = newTrack.list;
    self.currentTrack = newTrack.track;
    self.soloTrack = nil;
    
    if (self.listTrack.track.isCached) {
        [self initWithURL:[NSURL fileURLWithPath:[self.listTrack.track getCachePath]]];
    } else if ([self.listTrack.track.service isEqualToString:@"youtube"]) {
        [self setupYouTubeTrack:self.listTrack.track];
    } else if ([self.listTrack.track.service isEqualToString:@"soundcloud"]) {
        [self setupSoundCloudTrack:self.listTrack.track];
    } else if ([self.listTrack.track.service isEqualToString:@"grooveshark"]) {
        [self setupGrooveSharkTrack:self.listTrack.track];
    }
    
    [self setMediaInfo:newTrack.track withListName:newTrack.list.name];
    
    if ([self.list.type isEqualToString:@"party"] && self.list.active) {
        if (self.list.active) [JXRequest playTrack:[newTrack.track.identifier integerValue] inParty:[newTrack.list.identifier integerValue]];
    }
}

-(void)setMediaInfo:(Track *)track withListName:(NSString *)name
{
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    NSDictionary *songInfo = @{MPMediaItemPropertyArtist     :[track serviceString],
                               MPMediaItemPropertyTitle      :track.title,
                               MPMediaItemPropertyAlbumTitle :name};
    center.nowPlayingInfo = songInfo;
}

-(void)nextTrack
{
    if (!self.list) return;
    NSArray *tracks = nil;
    if (self.sortDescriptors) {
        tracks = [[self.list.tracks allObjects] sortedArrayUsingDescriptors:self.sortDescriptors];
    } else if ([self.list isPlaylist] || !self.list.active) {
        tracks = [[self.list.tracks allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    } else {
        tracks = [[self.list.tracks allObjects] sortedArrayUsingDescriptors:
                  @[[NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES],
                  [NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO],
                  [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]]];
    }
    if (!tracks || tracks.count == 0) return;
    
    NSUInteger index = [tracks indexOfObject:self.listTrack];
    
    if (index == NSNotFound) {
        ListTrack *listTrack = tracks[0];
        [self playTrack:listTrack];
    } else if (index < tracks.count-1) {
        ListTrack *listTrack = tracks[index+1];
        [self playTrack:listTrack];
    } else {
        ListTrack *listTrack = tracks[0];
        [self playTrack:listTrack];
    }
}

-(void)previousTrack
{
    NSArray *tracks = nil;
    if ([self.list.type isEqualToString:@"playlist"]) {
        tracks = [[self.list.tracks allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    } else {
        tracks = [[self.list.tracks allObjects] sortedArrayUsingDescriptors:
                  @[[NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES],
                  [NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO],
                  [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]]];
    }
    if (!tracks || tracks.count == 0) return;
    
    NSUInteger index = [tracks indexOfObject:self.listTrack];
    
    if (index == NSNotFound) {
        ListTrack *listTrack = tracks[0];
        [self playTrack:listTrack];
    } else if (index > 0) {
        ListTrack *listTrack = tracks[index-1];
        [self playTrack:listTrack];
    } else {
        ListTrack *listTrack = tracks[tracks.count-1];
        [self playTrack:listTrack];
    }
}

-(BOOL)togglePlayer
{
    if ([self isPlaying]) {
        [self.player pause];
        [self disableTimer:NO];
    } else if ([self isPaused]) {
        [self.player play];
        [self disableTimer:YES];
    }
    
    return [self isPlaying];
}

-(void)disableTimer:(BOOL)disable
{
    [UIApplication sharedApplication].idleTimerDisabled = disable;
}

-(void)removeFromSuperView
{
    [self.player.view removeFromSuperview];
}

-(void)setupYouTubeTrack:(Track *)track
{
    [self.delegate beganLoadingTrack];
    if (track.streamURL) {
        [self initWithURL:[NSURL URLWithString:track.streamURL]];
    } else {
        self.extractor = [[YouTubeExtractor alloc] initWithTrack:track quality:YouTubePlayerQualityLow andDelegate:self];
    }
}

-(void)setupSoundCloudTrack:(Track *)track
{
    [self.delegate beganLoadingTrack];
    [self initWithURL:[NSURL URLWithString:track.streamURL]];
}

-(void)setupGrooveSharkTrack:(Track *)track
{
    [self.delegate beganLoadingTrack];
    [self initWithURL:[NSURL URLWithString:track.streamURL]];
}

-(void)extractedURL:(NSURL *)url
{
    [self initWithURL:url];
}

-(void)failedToExtractURL
{
    [self.delegate failedToLoadTrack];
}

-(void)initWithURL:(NSURL *)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player setContentURL:url];
        [self disableTimer:YES];
        NSLog(@"LOAD STATE: %i",self.player.loadState);
        [self.session setActive:YES error:nil];
        [self.player setShouldAutoplay:YES];
        [self.player prepareToPlay];
        [self.player play];
    });
}



-(BOOL)isPlaying
{
    return self.player.playbackState == MPMoviePlaybackStatePlaying;
}

-(BOOL)isPaused
{
    return self.player.playbackState == MPMoviePlaybackStatePaused;
}

-(BOOL)isStopped
{
    return self.player.playbackState == MPMoviePlaybackStateStopped;
}

-(BOOL)isSeeking
{
    return self.player.playbackState == MPMoviePlaybackStateSeekingBackward ||
           self.player.playbackState == MPMoviePlaybackStateSeekingForward;
}

@end
