//
//  FeedCell.m
//  joox.fm
//
//  Created by Andrew Barba on 7/18/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "FeedCell.h"
#import "Joox.h"
#import "UIImageView+WebCache.h"
#import "JXFMAppDelegate.h"

@implementation FeedCell

-(void)initWithActivity:(Activity *)activity
{
    User *user = activity.listUser.user;
    if (!user) user = activity.listFollower.user;
    
    self.timeLabel.text = [Joox niceTime:activity.timestamp];
    self.listLabel.text = activity.list.name;
    self.trackLabel.text = activity.listTrack ? activity.listTrack.track.title : @"";
    self.userLabel.text = user.fullName;
    
    if ([activity.type isEqualToString:@"user"]) {
        self.userLabel.text = [self.userLabel.text stringByAppendingFormat:@" joined"];
        self.trackLabel.text = activity.list.name;
        self.listLabel.text = @"";
        self.typeImage.image = [UIImage imageNamed:@"user-white.png"];
        self.typeImage.highlightedImage = [UIImage imageNamed:@"user-gray.png"];
        self.typeView.backgroundColor = [Joox greenColor];
    } else if ([activity.type isEqualToString:@"track"]) {
        self.userLabel.text = [self.userLabel.text stringByAppendingFormat:@" added"];
        self.typeImage.image = [UIImage imageNamed:@"track-white.png"];
        self.typeImage.highlightedImage = [UIImage imageNamed:@"track-gray.png"];
        self.typeView.backgroundColor = [Joox blueColor];
    } else if ([activity.type isEqualToString:@"vote"]) {
        self.userLabel.text = [self.userLabel.text stringByAppendingFormat:@" voted for"];
        self.typeImage.image = [UIImage imageNamed:@"plusOne-white.png"];
        self.typeImage.highlightedImage = [UIImage imageNamed:@"plusOne-gray.png"];
        self.typeView.backgroundColor = [Joox orangeColor];
    } else if ([activity.type isEqualToString:@"follower"]) {
        self.userLabel.text = [self.userLabel.text stringByAppendingFormat:@" started following"];
        self.trackLabel.text = activity.list.name;
        self.listLabel.text = @"";
        self.typeImage.image = [UIImage imageNamed:@"user-white.png"];
        self.typeImage.highlightedImage = [UIImage imageNamed:@"user-gray.png"];
        self.typeView.backgroundColor = [Joox greenColor];
    }
    
    [self.profilePictureView setImageWithURL:[Joox getFacebookImageURL:user.fb]];    
    
    self.typeView.layer.cornerRadius = 10;
    self.typeView.layer.shadowRadius = 1;
    self.typeView.layer.shadowOpacity = 0.4;
    self.typeView.layer.shadowOffset = CGSizeMake(0, 0);
    self.typeView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.profilePictureView.layer.borderWidth = 2;
    self.profilePictureView.layer.borderColor = [UIColor colorWithWhite:0.95 alpha:1.0].CGColor;
    
    self.profilePictureView.clipsToBounds = NO;
    self.profilePictureView.layer.shadowRadius = 1;
    self.profilePictureView.layer.shadowOpacity = 0.5;
    self.profilePictureView.layer.shadowOffset = CGSizeMake(0, 0);
    self.profilePictureView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.profilePictureView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.profilePictureView.bounds].CGPath;
    
    /*
    self.infoView.layer.shadowRadius = 1;
    self.infoView.layer.shadowOpacity = 0.8;
    self.infoView.layer.shadowOffset = CGSizeMake(0, 0);
    self.infoView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.infoView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.infoView.bounds].CGPath;
     */
    
    self.bgView.layer.shadowRadius = 1;
    self.bgView.layer.shadowOpacity = 0.4;
    self.bgView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bgView.bounds].CGPath;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setSelected:selected];
}

-(void)setSelected:(BOOL)selected
{
    self.typeView.layer.shadowColor = selected ? [Joox blueColor].CGColor : [UIColor blackColor].CGColor;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [self setHighlighted:highlighted];
}

-(void)setHighlighted:(BOOL)highlighted
{
    self.typeView.layer.shadowRadius = highlighted ? 5 : 1;
    self.bgView.layer.shadowRadius = highlighted ? 5 : 1;
}

@end
