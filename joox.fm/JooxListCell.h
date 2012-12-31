//
//  JooxListCell.h
//  joox.fm
//
//  Created by Andrew Barba on 9/5/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JooxList+Get.h"

@interface JooxListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIView *profileImgContainer;
@property (nonatomic, weak) IBOutlet UIImageView *listImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastUpdateLabel;
@property (nonatomic, weak) IBOutlet UILabel *tracksLabel;
-(void)initWithList:(JooxList *)list;
@end
