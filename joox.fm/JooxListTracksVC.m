//
//  JooxListTracksVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxListTracksVC.h"
#import "JooxListTrackCell.h"
#import "JooxListTrackOptionCell.h"

@interface JooxListTracksVC ()
@property (nonatomic, strong) NSIndexPath *optionIndexPath;
@end

@implementation JooxListTracksVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.originalActive = [self.list.active boolValue];
    [self setUpResultsController];
    [self initRefreshControl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCells)
                                                 name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCells)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:[JXFMAppDelegate jooxPlayer].listTrack];
    if (indexPath) {
        CGFloat delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        });
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self hideOptionCell];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    if (self.originalActive != [self.list.active boolValue]) {
        if ([self.list.active boolValue]) {
            [[JXFMAppDelegate context] performBlockAndWait:^{
                [(Party *)self.list restart];
            }];
        }
        [self.parentViewController performSelector:@selector(activeStateChanged)];
    }
}

-(void)updateCells
{
    [self.tableView reloadData];
}

-(void)initRefreshControl
{
    self.refreshControl  = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self.presentingViewController action:@selector(fetch) forControlEvents:UIControlEventValueChanged];
}

-(void)setUpResultsController
{
    if ([self.list.type isEqualToString:@"playlist"]) {
        [self setUpPlaylist];
    } else if ([self.list.type isEqualToString:@"party"]) {
        [self setUpParty];
    }
}

-(void)setUpParty
{
    NSPredicate *predicate = nil;
    NSArray *sorting = nil;
    if (self.list.active) {
        predicate = [NSPredicate predicateWithFormat:@"list = %@ AND state != 1",self.list];
        sorting = @[[NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"list = %@",self.list];
        sorting = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    }
    
    if (!self.fetchedResultsController.fetchRequest) {
        [self setUpResultsControllerWithEntity:@"PartyTrack"
                                     predicate:predicate
                                         limit:0
                            andSortDescriptors:sorting];
    } else {
        [self.fetchedResultsController.fetchRequest setSortDescriptors:sorting];
        [self changeRequestPredicate:predicate];
    }
}

-(void)setUpPlaylist
{
    [self setUpResultsControllerWithEntity:@"PlaylistTrack"
                                 predicate:[NSPredicate predicateWithFormat:@"list = %@",self.list]
                                     limit:0
                        andSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier =  @"Track Cell";
    ListTrack *listTrack = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BOOL optionCell = NO;
    
    if (self.optionIndexPath.row == indexPath.row && self.optionIndexPath) {
        CellIdentifier =  @"Track Option Cell";
        optionCell = YES;
    }
    
    if (!optionCell) {
        JooxListTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell initWithTrack:listTrack];
        return cell;
    } else {
        JooxListTrackOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell initWithTrack:listTrack];
        return cell;
    }
}

-(void)hideOptionCell
{
    if (self.optionIndexPath.row > self.fetchedResultsController.fetchedObjects.count-1) {self.optionIndexPath = nil; return;}
    if (self.optionIndexPath != nil) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.optionIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.optionIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        self.optionIndexPath = nil;
        [self.tableView endUpdates];
    }
}

-(void)showOptionCell:(NSIndexPath *)optionIndexPath
{
    if (self.optionIndexPath.row > self.fetchedResultsController.fetchedObjects.count-1) {self.optionIndexPath = nil; return;}
    [self.tableView beginUpdates];
    self.optionIndexPath = optionIndexPath;
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.optionIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.optionIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

-(void)toggleOptionCell:(NSIndexPath *)indexPath
{
    if (self.optionIndexPath.row > self.fetchedResultsController.fetchedObjects.count-1) {self.optionIndexPath = nil; return;}
    if (indexPath.row == self.optionIndexPath.row && self.optionIndexPath) {
        [self hideOptionCell];
    } else {
        [self hideOptionCell];
        [self showOptionCell:indexPath];
    }
}

- (IBAction)vote:(UIButton *)sender
{
    if (sender.selected) return;
    JooxListTrackCell *cell = (JooxListTrackCell *)sender.superview.superview;
    ListTrack *track = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    ListTrack *listTrack = (ListTrack *)[[JXFMAppDelegate importContext] objectWithID:track.objectID];
    [self voteTrack:listTrack sender:cell];
}

-(void)voteTrack:(ListTrack *)listTrack sender:(JooxListTrackCell *)sender
{
    [sender.loadingView startAnimating];
    sender.voteButton.hidden = YES;
    if ([self.list.type isEqualToString:@"playlist"]) {
        [JXRequest voteTrack:[listTrack.track.identifier integerValue] forPlaylist:[self.list.identifier integerValue] onCompletion:^(BOOL success){
            if (success) {
                [self voteTrack:listTrack];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender.loadingView stopAnimating];
                sender.voteButton.hidden = NO;
            });
        }];
    } else if ([self.list.type isEqualToString:@"party"]) {
        [JXRequest voteTrack:[listTrack.track.identifier integerValue] forParty:[self.list.identifier integerValue] onCompletion:^(BOOL success){
            if (success) {
                [self voteTrack:listTrack];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender.loadingView stopAnimating];
                sender.voteButton.hidden = NO;
            });
        }];
    }
}

-(void)voteTrack:(ListTrack *)listTrack
{
    NSManagedObjectContext *context = listTrack.managedObjectContext;
    [context performBlockAndWait:^{
        [Vote createVoteForTrack:listTrack andUser:[Joox getUserInfo][@"fb"] inContext:context];
        listTrack.rating = @([listTrack.rating integerValue]+1);
    }];
    [JXFMAppDelegate updateContexts];
}

- (IBAction)deleteTrack:(UIButton *)sender
{
    if (!self.list.active) return;
    
    JooxListTrackOptionCell *cell = (JooxListTrackOptionCell *)sender.superview.superview.superview;
    ListTrack *track = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    ListTrack *listTrack = (ListTrack *)[[JXFMAppDelegate importContext] objectWithID:track.objectID];
    
    [self deleteTrack:listTrack sender:cell];
}

-(void)deleteTrack:(ListTrack *)listTrack sender:(JooxListTrackOptionCell *)cell
{
    [cell.loadingView startAnimating];
    cell.deleteButton.hidden = YES;
    if ([self.list.type isEqualToString:@"playlist"]) {
        [JXRequest removeTrack:[listTrack.track.identifier integerValue] fromPlaylist:[self.list.identifier integerValue] onCompletion:^(BOOL success){
            if (success) {
                self.optionIndexPath = nil;
                [self deleteTrackFromList:listTrack];
            } else {
                [cell.loadingView stopAnimating];
                cell.deleteButton.hidden = NO;
            }
        }];
    } else if ([self.list.type isEqualToString:@"party"]) {
        [JXRequest removeTrack:[listTrack.track.identifier integerValue] fromParty:[self.list.identifier integerValue] onCompletion:^(BOOL success){
            if (success) {
                self.optionIndexPath = nil;
                [self deleteTrackFromList:listTrack];
            } else {
                [cell.loadingView stopAnimating];
                cell.deleteButton.hidden = NO;
            }
        }];
    }
}

-(void)deleteTrackFromList:(ListTrack *)listTrack
{
    NSManagedObjectContext *context = listTrack.managedObjectContext;
    [context performBlockAndWait:^{
        [context deleteObject:listTrack];
    }];
    [JXFMAppDelegate updateContexts];
}

- (IBAction)play:(UIButton *)sender
{
    [JXFMAppDelegate jooxPlayer].tracks = self.fetchedResultsController.fetchedObjects;
    JooxListTrackOptionCell *cell = (JooxListTrackOptionCell *)sender.superview.superview.superview;
    ListTrack *track = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [[JXFMAppDelegate jooxPlayer] playTrack:track];
    [self.tableView reloadData];
    [self hideOptionCell];
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.parentViewController performSelector:@selector(showVideo:) withObject:@(YES)];
    });
}

- (IBAction)cacheTrack:(UIButton *)sender
{
    [JXFMAppDelegate jooxPlayer].tracks = self.fetchedResultsController.fetchedObjects;
    JooxListTrackOptionCell *cell = (JooxListTrackOptionCell *)sender.superview.superview.superview;
    ListTrack *track = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [[JXFMAppDelegate jooxDownloader] downloadTrack:track.track];
    [self hideOptionCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleOptionCell:indexPath];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
