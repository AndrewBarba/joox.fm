//
//  JooxListCell.m
//  joox.fm
//
//  Created by Andrew Barba on 9/5/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxListCell.h"
#import "JXFMAppDelegate+CoreData.h"

@implementation JooxListCell

-(void)initWithList:(JooxList *)list
{
    if ([list isPlaylist]) {
        if ([[JXFMAppDelegate jooxPlayer] isPlaying] &&
            [JXFMAppDelegate jooxPlayer].list == list)
        {
            self.listImageView.image = [UIImage imageNamed:@"list-blue.png"];
        } else {
            self.listImageView.image = [UIImage imageNamed:@"list-gray.png"];
        }
        
    } else if ([list isParty]) {
        if (!list.active) {
            self.listImageView.image = [UIImage imageNamed:@"party-gray.png"];
        } else {
            self.listImageView.image = [UIImage imageNamed:@"party-blue.png"];
        }
    }
    
    self.listImageView.layer.cornerRadius = 3;
    self.listImageView.clipsToBounds = YES;
    self.listImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.nameLabel.text = list.name;
    self.lastUpdateLabel.text = [NSString stringWithFormat:@"%@",[Joox niceTime:list.timestamp]];
    self.tracksLabel.text = [NSString stringWithFormat:@"%i songs",list.tracks.count];
    
    self.bgView.layer.shadowRadius = 1;
    self.bgView.layer.shadowOpacity = 0.4;
    self.bgView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bgView.bounds].CGPath;
    
    NSArray *users = [list.users allObjects];
    [self.profileImgContainer.subviews enumerateObjectsUsingBlock:^(UIImageView *view, NSUInteger index, BOOL *stop){
        if (index < users.count) {
            view.hidden = NO;
            ListUser *listUser = users[index];
            [view setImageWithURL:[Joox getFacebookImageURL:listUser.user.fb]];
            
            view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
            view.layer.borderWidth = 1;
            view.layer.cornerRadius = 3;
        } else {
            view.hidden = YES;
        }
    }];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setSelected:selected];
}

-(void)setSelected:(BOOL)selected
{
    [self setHighlighted:selected];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [self setHighlighted:highlighted];
}

-(void)setHighlighted:(BOOL)highlighted
{
    self.bgView.layer.shadowRadius = highlighted ? 5 : 1;
}

@end
