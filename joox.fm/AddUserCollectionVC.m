//
//  AddUserCollectionVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/5/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "AddUserCollectionVC.h"

@interface AddUserCollectionVC ()
@property (nonatomic, strong) NSArray *workingFriends;
@end

@implementation AddUserCollectionVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.collectionView registerClass:[FacebookUsersCell class] forCellWithReuseIdentifier:@"Facebook User Cell"];
    self.workingFriends = [NSArray array];
    self.friends = [NSArray array];
    [self fetchFriends];
}

-(void)fetchFriends
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"isFriend != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    self.friends = [[JXFMAppDelegate context] executeFetchRequest:request error:nil];
    if (!self.workingFriends.count) {
        self.workingFriends = [self.friends copy];
        NSLog(@"Fetched");
    }
    int64_t delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.collectionView reloadData];
    });
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.workingFriends.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookUsersCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Facebook User Cell" forIndexPath:indexPath];
    User *user = self.workingFriends[indexPath.row];
    [cell initWithFacebookUser:user andList:self.list];
    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UIViewController <UIScrollViewDelegate> *vc = (UIViewController <UIScrollViewDelegate> *)self.parentViewController;
    [vc scrollViewWillBeginDragging:scrollView];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookUsersCell *cell = (FacebookUsersCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell.loadingView startAnimating];
    User *user =  self.workingFriends[indexPath.row];
    if ([user.lists containsObject:self.list]) return;
    [self.delegate didSelectUser:user sender:cell];
}

-(void)searchFriends:(NSString *)query
{
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    dispatch_async(queue, ^{
        if (query.length) {
            self.workingFriends = [self.friends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@",query]];
        } else {
            self.workingFriends = [self.friends copy];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

@end
