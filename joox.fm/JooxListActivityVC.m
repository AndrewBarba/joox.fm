//
//  JooxListActivityVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxListActivityVC.h"

@interface JooxListActivityVC ()

@end

@implementation JooxListActivityVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpResultsController];
}

-(void)setUpResultsController
{
    [self setUpResultsControllerWithEntity:@"Activity"
                                 predicate:[NSPredicate predicateWithFormat:@"list = %@",self.list]
                                     limit:0
                        andSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Activity Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Activity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([activity.type isEqualToString:@"user"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ joined",activity.listUser.user.fullName];
        cell.imageView.image = [UIImage imageNamed:@"user.png"];
    }
    
    if ([activity.type isEqualToString:@"follower"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ started following",activity.listFollower.user.fullName];
        cell.imageView.image = [UIImage imageNamed:@"user.png"];
    }
    
    if ([activity.type isEqualToString:@"track"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ added %@",activity.listUser.user.fullName,activity.listTrack.track.title];
        cell.imageView.image = [UIImage imageNamed:@"track.png"];
    }
    
    if ([activity.type isEqualToString:@"vote"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ voted for %@",activity.listUser.user.fullName,activity.listTrack.track.title];
        cell.imageView.image = [UIImage imageNamed:@"plusOne.png"];
    }
    
    cell.detailTextLabel.text = [Joox niceTime:activity.timestamp];
    
    return cell;
}

@end
