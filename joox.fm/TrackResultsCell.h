//
//  TrackResultsCell.h
//  joox.fm
//
//  Created by Andrew Barba on 6/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTrack+Get.h"

@interface TrackResultsCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *trackImageView;
@property (nonatomic, strong) UILabel *trackTitleLabel;
@property (nonatomic, strong) UILabel *trackArtistLabel;
@property (nonatomic, strong) UIView *addView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UILabel *durationLabel;
-(void)initCellWithTrack:(NSDictionary *)track ofService:(NSString *)service;
-(void)initCellWithTrack:(ListTrack *)track;
@end
