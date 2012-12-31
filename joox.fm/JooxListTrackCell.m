//
//  JooxListTrackCell.m
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxListTrackCell.h"
#import "JXFMAppDelegate+CoreData.h"

@implementation JooxListTrackCell

-(void)initWithTrack:(ListTrack *)listTrack
{
    self.voteButton.layer.cornerRadius = 5;
    self.titleLabel.text = listTrack.track.title;
    self.userLabel.text = [NSString stringWithFormat:@"%@ - added by %@",
                           [listTrack.track durationString],listTrack.user.fullName];
    [self.voteButton setTitle:[NSString stringWithFormat:@"+%@",listTrack.rating]
                     forState:UIControlStateNormal];
    
    BOOL voted = [listTrack userDidVote:[[Joox getUserInfo][@"id"] integerValue]];
    if ([listTrack.list isParty]) voted = voted || ([listTrack didUpload] && [listTrack.rating integerValue] >= 1);
    
    if (voted) {
        [self setVoted];
    } else {
        [self setUnvoted];
    }
    
    if ([JXFMAppDelegate jooxPlayer].listTrack == listTrack)
    {
        [UIView animateWithDuration:0.3 animations:^{self.isPlayingView.layer.opacity = 1;}];
    } else {
        self.isPlayingView.layer.opacity = 0;
    }
    
    if ([listTrack.list isParty] && listTrack.list.active) {
        PartyTrack *partyTrack = (PartyTrack *)listTrack;
        self.isPlayingView.layer.opacity = ([partyTrack.state integerValue] != 2) ? 0 : 1;
    }
}

-(void)setVoted
{
    self.voteButton.selected = YES;
    self.voteButton.userInteractionEnabled = NO;
    self.voteButton.backgroundColor = [Joox blueColor];
}

-(void)setUnvoted
{
    self.voteButton.selected = NO;
    self.voteButton.userInteractionEnabled = YES;
    self.voteButton.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
}

-(void)initWithCachedTrack:(Track *)track
{    
    self.isPlayingView.hidden = !([JXFMAppDelegate jooxPlayer].soloTrack == track);
    if ([[JXFMAppDelegate jooxDownloader] isDownloading] && [JXFMAppDelegate jooxDownloader].track == track) {
        [self.loadingView startAnimating];
    } else {
        [self.loadingView stopAnimating];
    }
    self.titleLabel.text = track.title;
    self.userLabel.text = [NSString stringWithFormat:@"%@ - %@",[track durationString],[track serviceString]];
}

@end
