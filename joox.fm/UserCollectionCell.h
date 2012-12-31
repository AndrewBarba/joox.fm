//
//  UserCollectionCell.h
//  joox.fm
//
//  Created by Andrew Barba on 6/16/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *userImageView;
//@property (nonatomic, strong) FBProfilePictureView *profilePictureView;
@property (nonatomic, strong) UILabel *nameLabel;
-(void)initCellWithUser:(User *)user;
@end
