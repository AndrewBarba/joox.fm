//
//  InviteTVC.m
//  joox.fm
//
//  Created by Andrew Barba on 6/27/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "InviteTVC.h"
#import "InviteCell.h"
#import "Invite+Create.h"
#import "JXRequest.h"

@interface InviteTVC ()
@property (nonatomic, strong) NSTimer *updateTimer;
@end

@implementation InviteTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpResultsController];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetch) forControlEvents:UIControlEventValueChanged];
}

-(void)setEditInvites:(BOOL)editInvites
{
    _editInvites = editInvites;
    [self.tableView reloadData];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    [UIApplication sharedApplication].applicationIconBadgeNumber = controller.fetchedObjects.count;
}

-(void)fetch
{
    [JXRequest fetchAllInvites:^(NSUInteger count){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [UIApplication sharedApplication].applicationIconBadgeNumber = count;
        });
    }];
}

-(void)setUpResultsController
{
    [self setUpResultsControllerWithEntity:@"Invite"
                                 predicate:nil
                                     limit:0
                        andSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [self numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Invite Cell";
    InviteCell *cell = (InviteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Invite *invite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell initWithInvite:invite isEditting:self.editInvites];
    return cell;
}

- (IBAction)accept:(UIButton *)sender
{
    sender.selected = YES;
    sender.userInteractionEnabled = NO;
    InviteCell *cell = (InviteCell *)sender.superview.superview.superview;
    [cell.loadingView startAnimating];
    Invite *invite = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [JXRequest acceptInvite:invite onCompletion:^(NSString *result){
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.parentViewController performSelector:@selector(toggleInvites)];
                [cell.loadingView stopAnimating];
                cell.loadingView.hidden = YES;
                sender.userInteractionEnabled = YES;
                sender.selected = NO;
            });
            [JXRequest fetchPlaylist:[invite.playlistID integerValue] onCompletion:nil];
            [JXFMAppDelegate deleteObject:invite];
        }
    }];
}

- (IBAction)decline:(UIButton *)sender
{
    InviteCell *cell = (InviteCell *)sender.superview.superview.superview;
    Invite *invite = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [JXRequest declineInvite:invite onCompletion:nil];
    [JXFMAppDelegate deleteObject:invite];
}

@end
