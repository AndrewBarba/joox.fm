//
//  TrackResultsCell.m
//  joox.fm
//
//  Created by Andrew Barba on 6/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "TrackResultsCell.h"
#import "JXRequest.h"
#import "Track+Get.h"

@implementation TrackResultsCell

#define ServiceYouTube     @"youtube"
#define ServiceVimeo       @"vimeo"
#define ServiceSoundCloud  @"soundcloud"
#define ServiceGrooveShark @"grooveshark"

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.clipsToBounds = YES;
        self.clipsToBounds = NO;
        
        self.trackTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height/2, self.contentView.bounds.size.width, self.contentView.bounds.size.height/2)];
        [self.trackTitleLabel setFont:[UIFont fontWithName:@"Verdana" size:11]];
        [self.trackTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.trackTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.trackTitleLabel setNumberOfLines:2];
        [self.contentView addSubview:self.trackTitleLabel];
        
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.9;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.selectedBackgroundView.layer.shadowRadius = 2;
        self.selectedBackgroundView.layer.shadowOpacity = 0.9;
        self.selectedBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
        self.selectedBackgroundView.layer.shadowColor = [UIColor redColor].CGColor;
        self.selectedBackgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.addView = [[UIView alloc] initWithFrame:self.trackTitleLabel.bounds];
        self.addView.backgroundColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.addView];
        self.addView.hidden = YES;
        
        self.trackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height/2)];
        self.trackImageView.clipsToBounds = YES;
        self.trackImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.trackImageView];
        self.trackImageView.hidden = YES;
        
        self.trackArtistLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 152, 35)];
        [self.trackArtistLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
        [self.trackArtistLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.trackArtistLabel setNumberOfLines:2];
        [self.contentView addSubview:self.trackArtistLabel];
        self.trackArtistLabel.hidden = YES;
        self.trackArtistLabel.backgroundColor = [UIColor clearColor];
        
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.contentView.bounds.size.height/2)-15, self.contentView.bounds.size.width*0.4, 15)];
        [self.durationLabel setFont:[UIFont fontWithName:@"Verdana" size:10]];
        [self.durationLabel setTextColor:[UIColor whiteColor]];
        [self.durationLabel setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        [self.durationLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.durationLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.durationLabel];
        
        self.loadingView = [[UIActivityIndicatorView alloc] initWithFrame:self.contentView.bounds];
        self.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.loadingView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
        [self.contentView addSubview:self.loadingView];
    }
    return self;
}

-(void)toggleCell
{
    
}

-(void)initCellWithTrack:(NSDictionary *)track ofService:(NSString *)service
{
    if ([service isEqualToString:ServiceYouTube]) {
        [self setUpYouTubeCell:track];
    } else if ([service isEqualToString:ServiceSoundCloud]) {
        [self setUpSoundCloudCell:track];
    } else if ([service isEqualToString:ServiceGrooveShark]) {
        [self setUpGrooveSharkCell:track];
    } else if ([service isEqualToString:ServiceVimeo]) {
        [self setUpVimeoCell:track];
    }
}

-(void)initCellWithTrack:(ListTrack *)track
{
    self.trackTitleLabel.text = track.track.title;
    NSString *path = track.track.artworkURL;
    NSURL *url = [NSURL URLWithString:path];
    [self.trackImageView setImageWithURL:url];
    self.trackImageView.hidden = NO;
    self.trackArtistLabel.hidden = YES;
    self.durationLabel.text = [track.track durationString];
}

-(void)setUpYouTubeCell:(NSDictionary *)track
{
    self.trackTitleLabel.text = track[@"title"];
    NSString *path = track[@"thumbnail"][@"hqDefault"];
    NSURL *url = [NSURL URLWithString:path];
    [self.trackImageView setImageWithURL:url];
    self.trackImageView.hidden = NO;
    self.trackArtistLabel.hidden = YES;
    self.durationLabel.text = [Joox durationString:[track[@"duration"] integerValue]];
    self.durationLabel.hidden = NO;
}

-(void)setUpSoundCloudCell:(NSDictionary *)track
{
    self.trackTitleLabel.text = [NSString stringWithFormat:@"%@ - %@",track[@"user"][@"username"],track[@"title"]];
    NSString *path = [track[@"artwork_url"] class] != [NSNull class] ? track[@"artwork_url"] : track[@"user"][@"avatar_url"];
    NSURL *url = [NSURL URLWithString:path];
    [self.trackImageView setImageWithURL:url];
    self.trackImageView.hidden = NO;
    self.trackArtistLabel.hidden = YES;
    self.durationLabel.text = [Joox durationString:([track[@"duration"] integerValue]/1000)];
    self.durationLabel.hidden = NO;
}

-(void)setUpVimeoCell:(NSDictionary *)track
{
    
}

-(void)setUpGrooveSharkCell:(NSDictionary *)track
{
    self.trackTitleLabel.text = [NSString stringWithFormat:@"%@ - %@",track[@"ArtistName"],track[@"SongName"]];
    self.trackImageView.hidden = NO;
    self.trackArtistLabel.hidden = YES;
    
    NSString *path = @"http://images.grooveshark.com/static/albums/200_";
    path = [track[@"CoverArtFilename"] isEqualToString:@""] ? @"http://joox.fm/img/gs12.png" : [path stringByAppendingFormat:@"%@",track[@"CoverArtFilename"]];
    NSURL *url = [NSURL URLWithString:path];
    [self.trackImageView setImageWithURL:url];
    self.durationLabel.hidden = YES;
}

@end
