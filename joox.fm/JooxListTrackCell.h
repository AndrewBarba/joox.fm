//
//  JooxListTrackCell.h
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTrack+Get.h"
#import "Track+Get.h"
#import "User+Get.h"
#import "JooxList+Get.h"

@interface JooxListTrackCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *userLabel;
@property (nonatomic, weak) IBOutlet UIButton *voteButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *isPlayingView;
-(void)initWithTrack:(ListTrack *)listTrack;
-(void)initWithCachedTrack:(Track *)track;
-(void)setVoted;
-(void)setUnvoted;
@end
