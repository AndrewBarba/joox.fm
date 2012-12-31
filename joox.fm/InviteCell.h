//
//  InviteCell.h
//  joox.fm
//
//  Created by Andrew Barba on 6/27/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invite+Create.h"

@interface InviteCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *playlistNameLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIButton *acceptButton;
@property (nonatomic, weak) IBOutlet UIButton *declineButton;
-(void)initWithInvite:(Invite *)invite isEditting:(BOOL)editting;
@end
