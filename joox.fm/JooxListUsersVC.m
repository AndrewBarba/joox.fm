//
//  JooxListUsersVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxListUsersVC.h"
#import "UserCollectionCell.h"

@interface JooxListUsersVC ()
@property (nonatomic) CGFloat lastWidth;
@end

#define LayoutSizeNormal 100
#define LayoutSizeLarge 152
#define LayoutSizeSmall 73

@implementation JooxListUsersVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[UserCollectionCell class] forCellWithReuseIdentifier:@"User Cell"];
    [self setUpResultsController];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPinch:)];
    [self.collectionView addGestureRecognizer:pinch];
}

-(void)setUpResultsController
{
    [self setUpResultsControllerWithEntity:@"ListUser"
                                 predicate:[NSPredicate predicateWithFormat:@"list = %@ AND active = YES",self.list]
                                     limit:0
                        andSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"User Cell" forIndexPath:indexPath];
    ListUser *listUser = [self.fetchedResultsController objectAtIndexPath:indexPath];
    User *user = listUser.user;
    [cell initCellWithUser:user];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *path = [NSString stringWithFormat:@"fb://profile/%@",user.user.fb];
    NSURL *url = [NSURL URLWithString:path];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)setLayoutWithItemWidth:(CGFloat)width
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(width, width);
    self.lastWidth = width;
}

- (void)userDidPinch:(UIPinchGestureRecognizer *)sender
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    if (!self.lastWidth) self.lastWidth = layout.itemSize.width;
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        layout.itemSize = CGSizeMake(self.lastWidth*sender.scale, self.lastWidth*sender.scale);
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender.velocity >= 0) {
            if (layout.itemSize.width > 120) {
                [self setLayoutWithItemWidth:LayoutSizeLarge];
            } else if (layout.itemSize.width < 80) {
                [self setLayoutWithItemWidth:LayoutSizeSmall];
            } else {
                [self setLayoutWithItemWidth:LayoutSizeNormal];
            }
        } else if (sender.velocity < 0) {
            if (layout.itemSize.width > 140) {
                [self setLayoutWithItemWidth:LayoutSizeLarge];
            } else if (layout.itemSize.width < 90) {
                [self setLayoutWithItemWidth:LayoutSizeSmall];
            } else {
                [self setLayoutWithItemWidth:LayoutSizeNormal];
            }
        }
    }
    
    if (layout.itemSize.width <= LayoutSizeSmall) {
        layout.itemSize = CGSizeMake(LayoutSizeSmall, LayoutSizeSmall);
    }
    
    if (layout.itemSize.width >= LayoutSizeLarge) {
        layout.itemSize = CGSizeMake(LayoutSizeLarge, LayoutSizeLarge);
    }
}

@end
