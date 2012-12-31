//
//  InviteCell.m
//  joox.fm
//
//  Created by Andrew Barba on 6/27/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "InviteCell.h"
#import "UIImageView+WebCache.h"
#import "Joox.h"

@implementation InviteCell

-(void)initWithInvite:(Invite *)invite isEditting:(BOOL)editting
{
    if (editting) {
        [UIView animateWithDuration:0.2 animations:^{
            self.acceptButton.layer.opacity = 0;
            self.declineButton.layer.opacity = 1;
        } completion:^(BOOL done){
            self.acceptButton.hidden = YES;
            self.declineButton.hidden = NO;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.acceptButton.layer.opacity = 1;
            self.declineButton.layer.opacity = 0;
        }completion:^(BOOL done){
            self.acceptButton.hidden = NO;
            self.declineButton.hidden = YES;
        }];
    }
    
    self.userNameLabel.text = invite.userName;
    self.playlistNameLabel.text = invite.playlistName;
    [self.userImageView setImageWithURL:[Joox getFacebookImageURL:invite.userFB]];
    [self initStyles];
    self.loadingView.frame = self.acceptButton.frame;
}

-(void)initStyles
{
    
}

@end
