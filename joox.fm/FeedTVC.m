//
//  FeedTVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/1/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "FeedTVC.h"
#import "JXFMAppDelegate+CoreData.h"
#import "JXRequest.h"
#import "Joox.h"
#import "JooxListVC.h"
#import "FeedCell.h"
#import "AB.h"

@interface FeedTVC ()
@property (weak, nonatomic) IBOutlet UIButton *plusOneButton;
@property (weak, nonatomic) IBOutlet UIButton *trackButton;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@end

@implementation FeedTVC

-(void)fetch
{
    [JXRequest fetchEverything:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.tableView reloadData];
}

// ACTIONS

- (IBAction)filterContent:(UIButton *)sender
{    
    NSString *filter;
    if (sender == self.plusOneButton) filter = @"'vote'";
    if (sender == self.trackButton)   filter = @"'track'";
    if (sender == self.userButton)    filter = @"'user'";
    if (sender.selected)              filter = @"type";
    if (filter) {
        NSString *formatString = [NSString stringWithFormat:@"type = %@",filter];
        [self changeRequestPredicate:[NSPredicate predicateWithFormat:formatString]];
        [self.actionsView.subviews map:^(UIButton *button){
            button.selected = (button == sender) ? !sender.selected : NO;
        }];
    }
}


// DATA SETUP

-(void)setUpResultsController
{
    [self setUpResultsControllerWithEntity:@"Activity"
                                 predicate:nil
                                     limit:50
                        andSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Activity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([activity.type isEqualToString:@"user"]) return 80;
    if ([activity.type isEqualToString:@"vote"]) return 80;
    return 115;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Activity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *CellIdentifier = @"Activity Cell";
    if ([activity.type isEqualToString:@"user"]) CellIdentifier = @"Activity Cell Join";
    if ([activity.type isEqualToString:@"vote"]) CellIdentifier = @"Activity Cell Vote";
    
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell initWithActivity:activity];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show List"]) {
        Activity *activity = (Activity *)sender;
        JooxListVC *vc = segue.destinationViewController;
        vc.list = activity.list;
        
        if (!([activity.list isParty] && activity.list.active)) {
            if (activity.listTrack) [[JXFMAppDelegate jooxPlayer] playTrack:activity.listTrack];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Activity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"Show List" sender:activity];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

@end
