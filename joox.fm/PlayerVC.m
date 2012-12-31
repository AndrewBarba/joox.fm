//
//  PlayerVC.m
//  joox.fm
//
//  Created by Andrew Barba on 8/29/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "PlayerVC.h"
#import "JXFMAppDelegate.h"

@interface PlayerVC ()
@property (nonatomic, strong) JooxPlayer *jooxPlayer;
@property (nonatomic, strong) NSTimer *timer;

// Outlets
@property (weak, nonatomic) IBOutlet UIImageView *serviceImageView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTrackLabel;
@end

@implementation PlayerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.jooxPlayer = [JXFMAppDelegate jooxPlayer];
    [self resetInfo];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.jooxPlayer.delegate = self;
    [self freshUpdate];
}

-(void)resetInfo
{
    self.currentLabel.text = @"- -";
    self.remainingLabel.text = @"- -";
    self.serviceImageView.image = nil;
    self.serviceImageView.hidden = YES;
    self.pauseButton.hidden = YES;
    self.playButton.hidden = NO;
    self.currentTrackLabel.text = @"there is currently no track playing";
    [self.progressSlider setValue:0];
    [self.loading stopAnimating];
}

-(void)initTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

-(void)timerFired:(NSTimer *)timer
{
    [self updateInfo];
}

-(void)updateInfo
{
    CGFloat current = self.jooxPlayer.player.currentPlaybackTime;
    CGFloat duration = self.jooxPlayer.player.duration;
    CGFloat percentComplete = 0;
    if (current != 0 && duration != 0) {
        percentComplete = current / duration;
    }
    if (isnan(percentComplete)) percentComplete = 0;
    if (![self.jooxPlayer isSeeking]) [self.progressSlider setValue:percentComplete animated:YES];
    [self setCurrentLabelWithPercentComplete:percentComplete];
    [self setRemainingLabelWithPercentComplete:percentComplete];
}

-(void)freshUpdate
{
    [self resetInfo];
    if (!self.jooxPlayer.currentTrack) return;
    [self updateInfo];
    [self initTimer];
    self.currentTrackLabel.text = self.jooxPlayer.currentTrack.title;
    NSString *service = self.jooxPlayer.currentTrack.service;
    if ([service isEqualToString:@"youtube"]) {
        [self.videoView addSubview:self.jooxPlayer.player.view];
        [self.jooxPlayer.player.view setFrame:self.videoView.bounds];
        [self.serviceImageView setImage:[UIImage imageNamed:@"youtube-large.png"]];
        self.videoView.hidden = YES;
        self.serviceImageView.hidden = NO;
        self.fullScreenButton.hidden = NO;
    } else if ([service isEqualToString:@"soundcloud"]) {
        [self.serviceImageView setImage:[UIImage imageNamed:@"soundcloud-large.png"]];
        self.videoView.hidden = YES;
        self.serviceImageView.hidden = NO;
        self.fullScreenButton.hidden = YES;
    }
    if ([self.jooxPlayer isPlaying]) {
        self.playButton.hidden = YES;
        self.pauseButton.hidden = NO;
    } else {
        self.playButton.hidden = NO;
        self.pauseButton.hidden = YES;
    }
}

- (IBAction)sliderChanged:(UISlider *)sender
{
    //    if ([self.jooxPlayer isPlaying]) [self.jooxPlayer.player pause];
    CGFloat percent = sender.value;
    [self setCurrentLabelWithPercentComplete:percent];
    [self setRemainingLabelWithPercentComplete:percent];
    
    NSTimeInterval duration = self.jooxPlayer.player.duration;
    NSTimeInterval time = duration * percent;
    [self.jooxPlayer.player setCurrentPlaybackTime:time];
}

- (IBAction)nextSong:(id)sender
{
    [self.jooxPlayer nextTrack];
}

- (IBAction)previousSong:(id)sender
{
    [self.jooxPlayer previousTrack];
}

- (IBAction)playSong:(id)sender
{
    if (!self.jooxPlayer.currentTrack) return;
    [self.jooxPlayer.player play];
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (IBAction)pauseSong:(id)sender
{
    [self.jooxPlayer.player pause];
    self.pauseButton.hidden = YES;
    self.playButton.hidden = NO;
}

- (IBAction)enterFullScreen:(id)sender
{
    [self.jooxPlayer.player setFullscreen:YES animated:YES];
    [self.jooxPlayer.player setScalingMode:MPMovieScalingModeAspectFit];
}

-(void)setCurrentLabelWithPercentComplete:(CGFloat)percent
{
    NSTimeInterval duration = self.jooxPlayer.player.duration;
    NSInteger complete = duration * percent;
    NSInteger min = complete / 60;
    NSInteger sec = complete % 60;
    self.currentLabel.text = [NSString stringWithFormat:@"%i:%02i",min,sec];
}

-(void)setRemainingLabelWithPercentComplete:(CGFloat)percent
{
    NSTimeInterval duration = self.jooxPlayer.player.duration;
    NSInteger remaining = duration - (duration * percent);
    NSInteger min = remaining / 60;
    NSInteger sec = remaining % 60;
    self.remainingLabel.text = [NSString stringWithFormat:@"%i:%02i",min,sec];
}

-(void)currentTrackChanged:(Track *)track
{
    [self freshUpdate];
}

-(void)playerDidPause
{
    [self.timer invalidate];
    self.timer = nil;
    self.playButton.hidden = NO;
    self.pauseButton.hidden = YES;
    [self updateInfo];
}

-(void)playerDidStartPlaying
{
    [self.loading stopAnimating];
    [self.timer fire];
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
    [self updateInfo];
    [self initTimer];
}

-(void)playerIsSeeking
{
    
}

-(void)loadStateChanged:(NSInteger)state
{
    
}

-(void)beganLoadingTrack
{
    [self.loading startAnimating];
    [self.progressSlider setValue:0 animated:YES];
    self.playButton.hidden = YES;
    self.pauseButton.hidden = YES;
    self.currentLabel.text = @"- -";
    self.remainingLabel.text = @"- -";
}

-(void)failedToLoadTrack
{
    [self resetInfo];
    [Joox alert:[NSString stringWithFormat:@"We're sorry but %@ appears to be restricted by YouTube or you may have lost your network connection. Please check your connection and try again",self.jooxPlayer.currentTrack.title] withTitle:@"Failed to Load"];
    [self.jooxPlayer nextTrack];
}

-(void)willExitFullScreen
{
    [self.jooxPlayer.player setControlStyle:MPMovieControlStyleNone];
}

-(void)didExitFullScreen
{
    
}

-(void)didEnterFullScreen
{
    [self.jooxPlayer.player setControlStyle:MPMovieControlStyleFullscreen];
}

@end