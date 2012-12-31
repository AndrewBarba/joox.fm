//
//  FeedCell.h
//  joox.fm
//
//  Created by Andrew Barba on 7/18/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Get.h"
#import "Track+Get.h"
#import "JooxList+Get.h"
#import "Activity+Create.h"
#import "ListTrack+Create.h"
#import "ListUser+Get.h"
#import "PlaylistFollower+Create.h"

@interface FeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *typeView;
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *listLabel;
-(void)initWithActivity:(Activity *)activity;
@end
