//
//  JooxListsTVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/1/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxListsTVC.h"
#import "JXFMAppDelegate+CoreData.h"
#import "JXRequest.h"
#import "JooxListVC.h"
#import "JooxListCell.h"

@interface JooxListsTVC ()
@property (weak, nonatomic) IBOutlet UIView *actionsView;
@end

@implementation JooxListsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpResultsController];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self.parentViewController action:@selector(fetch) forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)setUpResultsController
{
    [self setUpResultsControllerWithEntity:@"JooxList"
                                 predicate:nil
                                     limit:0
                        andSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JooxListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JooxList Cell"];
    JooxList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell initWithList:list];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    JooxList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return !([list isParty] && [list.active boolValue] && [list isHost]);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JooxList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([list class] == [Playlist class]) {
            Playlist *playlist = (Playlist *)list;
            if (playlist.following) {
                [JXRequest unfollowPlaylist:[playlist.identifier integerValue] onCompletion:nil];
            } else {
                [JXRequest removeUserFromPlaylist:[playlist.identifier integerValue] onCompletion:nil];
            }
        } else if ([list class] == [Party class]) {
            [JXRequest removeUserFromParty:[list.identifier integerValue] onCompletion:nil];
        }
        [JXFMAppDelegate deleteObject:list];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JooxList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"Show List" sender:list];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show List"]) {
        JooxList *list = (JooxList *)sender;
        JooxListVC *vc = segue.destinationViewController;
        vc.list = list;
    }
}

@end
