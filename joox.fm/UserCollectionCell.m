//
//  UserCollectionCell.m
//  joox.fm
//
//  Created by Andrew Barba on 6/16/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "UserCollectionCell.h"
#import "Joox.h"
#import <QuartzCore/QuartzCore.h>
#import "JXRequest.h"

@implementation UserCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.userImageView.clipsToBounds = YES;
        [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.userImageView];
        self.userImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.userImageView.layer.opacity = 0;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-30, self.bounds.size.width, 30)];
        self.nameLabel.font = [UIFont fontWithName:@"Verdana" size:10];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.4];
        self.nameLabel.hidden = (self.bounds.size.width < 55);
        [self.contentView addSubview:self.nameLabel];
        
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.layer.shadowRadius = 1;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    self.nameLabel.frame = CGRectMake(0, self.bounds.size.height-15, self.bounds.size.width, 15);
    
    self.nameLabel.hidden = (self.bounds.size.width < 75);
}

-(void)initCellWithUser:(User *)user
{    
    [self.userImageView setImageWithURL:[Joox getFacebookImageURL:[NSString stringWithFormat:@"%@",user.fb]]];
    [UIView animateWithDuration:0.25 animations:^{self.userImageView.layer.opacity = 1;}];
    self.nameLabel.text = user.fullName;
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"bounds" context:nil];
}

@end
