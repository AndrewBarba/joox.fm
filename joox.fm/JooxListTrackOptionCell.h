//
//  JooxListTrackOptionCell.h
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

@interface JooxListTrackOptionCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIView *isPlayingView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, weak) IBOutlet UILabel *updateLabel;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *cacheButton;
@property (nonatomic, weak) IBOutlet UIView *imageBackgroundView;
-(void)initWithTrack:(ListTrack *)listTrack;
@end
