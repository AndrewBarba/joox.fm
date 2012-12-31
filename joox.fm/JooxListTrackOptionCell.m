//
//  JooxListTrackOptionCell.m
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxListTrackOptionCell.h"
#import "JXFMAppDelegate+CoreData.h"

@implementation JooxListTrackOptionCell

-(void)initWithTrack:(ListTrack *)listTrack
{
    [self.userImageView setImageWithURL:[Joox getFacebookImageURL:listTrack.user.fb]];
    [self.loadingView stopAnimating];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"h:mm a"];
    self.updateLabel.text = [NSString stringWithFormat:@"added %@",[Joox niceTime:listTrack.timestamp]];
    
    if (listTrack.list.active && [listTrack.user.fb isEqualToString:[Joox getUserInfo][@"fb"]]) {
        self.userImageView.hidden = YES;
        self.deleteButton.hidden = NO;
    } else {
        self.userImageView.hidden = NO;
        self.deleteButton.hidden = YES;
    }
    
    if ([listTrack.list isParty]) {
        PartyTrack *partyTrack = (PartyTrack *)listTrack;
        if ([partyTrack.state isEqualToNumber:@(2)]) {
            self.userImageView.hidden = NO;
            self.deleteButton.hidden = YES;
        }
    }
    
    if ([JXFMAppDelegate jooxPlayer].listTrack == listTrack)
    {
        [UIView animateWithDuration:0.3 animations:^{self.isPlayingView.layer.opacity = 1;}];
    } else {
        self.isPlayingView.layer.opacity = 0;
    }
    
    self.cacheButton.selected = [listTrack.track.isCached boolValue];
    self.cacheButton.userInteractionEnabled = ![listTrack.track.isCached boolValue];
    
    if ([listTrack.list isParty] && listTrack.list.active) {
        self.cacheButton.hidden = YES;
        PartyTrack *partyTrack = (PartyTrack *)listTrack;
        self.isPlayingView.layer.opacity = ([partyTrack.state integerValue] != 2) ? 0 : 1;
        self.playButton.hidden = ![listTrack.list isHost];
    } else if ([listTrack.list isParty]) {
        self.cacheButton.hidden = [[JXFMAppDelegate jooxDownloader] isDownloading] && ![listTrack.track isCached];
    } else {
        self.cacheButton.hidden = [[JXFMAppDelegate jooxDownloader] isDownloading] && ![listTrack.track isCached];
    }
    
    self.imageBackgroundView.layer.shadowRadius = 2;
    self.imageBackgroundView.layer.shadowOpacity = 1;
    self.imageBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    self.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageBackgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageBackgroundView.bounds].CGPath;
}

@end
