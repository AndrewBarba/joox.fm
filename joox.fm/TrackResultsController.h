//
//  TrackResultsController.h
//  joox.fm
//
//  Created by Andrew Barba on 6/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "CoreDataCollectionViewController.h"
#import "TrackResultsCell.h"

@protocol TrackResultsDelegate <NSObject>
-(void)userDidSelectTrack:(NSDictionary *)track withService:(NSString *)service fromCell:(TrackResultsCell *)cell;
//-(void)userDidSelectTrack:(ListTrack *)track;
@end

@interface TrackResultsController : CoreDataCollectionViewController
@property (nonatomic, weak) id <TrackResultsDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic, strong) NSString *service;
@end
