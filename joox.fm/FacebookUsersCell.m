//
//  FacebookUsersCell.m
//  joox.fm
//
//  Created by Andrew Barba on 7/5/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "FacebookUsersCell.h"
#import "UIImageView+WebCache.h"
#import "Joox.h"

@implementation FacebookUsersCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.clipsToBounds = YES;
        self.clipsToBounds = NO;

        self.userImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.userImageView.clipsToBounds = YES;
        self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.userImageView];
        
        self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 72, 100, 28)];
        [self.userNameLabel setFont:[UIFont fontWithName:@"Verdana" size:11]];
        [self.userNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.userNameLabel setNumberOfLines:2];
        self.userNameLabel.textColor = [UIColor whiteColor];
        self.userNameLabel.textAlignment = NSTextAlignmentCenter;
        self.userNameLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
        //self.userNameLabel.shadowColor = [UIColor darkGrayColor];
        //self.userNameLabel.shadowOffset = CGSizeMake(0, 1);
        [self.contentView addSubview:self.userNameLabel];
        
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.successImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 20, 50, 50)];
        self.successImageView.clipsToBounds = YES;
        self.successImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.successImageView];
        self.successImageView.image = [UIImage imageNamed:@"checkmark_64.png"];
        
        self.loadingView = [[UIActivityIndicatorView alloc] initWithFrame:self.contentView.bounds];
        self.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.loadingView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
        [self.contentView addSubview:self.loadingView];
    }
    return self;
}

-(void)initWithFacebookUser:(User *)user andList:(JooxList *)list
{
    self.userNameLabel.text = user.fullName;
    [self.userImageView setImageWithURL:[Joox getFacebookImageURL:user.fb]];
    self.successImageView.hidden = ![self isUser:user inList:list];
}

-(BOOL)isUser:(User *)user inList:(JooxList *)list
{
    BOOL inList = NO;
    for (ListUser *listUser in list.users) {
        if (listUser.user == user && [listUser.active boolValue]) {
            inList = YES;
        }
    }
    return inList;
}

@end
