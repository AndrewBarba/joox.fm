//
//  AddUserCollectionVC.h
//  joox.fm
//
//  Created by Andrew Barba on 7/5/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "CoreDataCollectionViewController.h"
#import "FacebookUsersCell.h"

@protocol FacebookUsersDelegate <NSObject>
-(void)didSelectUser:(User *)user sender:(FacebookUsersCell *)cell;
@end

@interface AddUserCollectionVC : CoreDataCollectionViewController
@property (nonatomic, weak) id <FacebookUsersDelegate> delegate;
@property (nonatomic, strong) JooxList *list;
@property (nonatomic, strong) NSArray *friends;
-(void)searchFriends:(NSString *)query;
-(void)fetchFriends;
@end
