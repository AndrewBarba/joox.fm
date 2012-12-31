//
//  TrackResultsController.m
//  joox.fm
//
//  Created by Andrew Barba on 6/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "TrackResultsController.h"
#import "JXRequest.h"

@implementation TrackResultsController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[TrackResultsCell class] forCellWithReuseIdentifier:@"Add Track Cell"];
}

-(void)setTracks:(NSMutableArray *)tracks
{
    if (_tracks != tracks) {
        _tracks = tracks;
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tracks.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrackResultsCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Add Track Cell" forIndexPath:indexPath];
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    [cell initCellWithTrack:track ofService:self.service];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    TrackResultsCell *cell = (TrackResultsCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell.loadingView startAnimating];
    [self.delegate userDidSelectTrack:track withService:self.service fromCell:cell];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UIViewController <UIScrollViewDelegate> *vc = (UIViewController <UIScrollViewDelegate> *)self.parentViewController;
    [vc scrollViewWillBeginDragging:scrollView];
}

@end
