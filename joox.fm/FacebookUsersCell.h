//
//  FacebookUsersCell.h
//  joox.fm
//
//  Created by Andrew Barba on 7/5/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXFMAppDelegate+CoreData.h"
#import "User+Get.h"
#import "JooxList+Get.h"

@interface FacebookUsersCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UIImageView *successImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
-(void)initWithFacebookUser:(User *)user andList:(JooxList *)list;
@end
