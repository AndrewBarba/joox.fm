//
//  JooxListVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JooxListVC.h"
#import "UITableView+Reorder.h"
#import "UICollectionView+Reorder.h"

@interface JooxListVC ()

// Controllers
@property (nonatomic, strong) JooxListActivityVC *activityTVC;
@property (nonatomic, strong) JooxListTracksVC   *tracksTVC;
@property (nonatomic, strong) JooxListUsersVC    *usersCVC;
@property (nonatomic) BOOL appeared;

// Fetcher
@property (nonatomic, strong) JXFMFetcher *listFetcher;

// Outlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *peopleButton;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UIButton *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *ratingButton;
@property (weak, nonatomic) IBOutlet UIButton *peopleTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *alphabetButton;
@property (weak, nonatomic) IBOutlet UIButton *addTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *addUserButton;
@property (weak, nonatomic) IBOutlet UIView *listButtonView;
@property (weak, nonatomic) IBOutlet UIView *peopleButtonView;
@property (weak, nonatomic) IBOutlet UIButton *startPartyButton;
@property (weak, nonatomic) IBOutlet UIButton *endPartyButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIButton *allTracksButton;
@property (weak, nonatomic) IBOutlet UIButton *restartPartyButton;
@end

@implementation JooxListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [JXFMAppDelegate jooxDownloader].delegate = self;
    [self initViews];
    [self initScrollView];
    [self fetch];
    self.listFetcher = [[JXFMFetcher alloc] initWithList:self.list];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listTrackChanged:)
                                                 name:JooxPlayerListTrackChangedNotification \
                                               object:[JXFMAppDelegate jooxPlayer]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initScrollView];
    [self initStyles];
    if (!self.appeared) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
        if ([self.list.tracks containsObject:[JXFMAppDelegate jooxPlayer].listTrack])
        {
            [self showVideo:NO];
        }
        self.appeared = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[JXFMAppDelegate jooxDownloader] isDownloading]) [self showProgressbar];
}

-(void)listTrackChanged:(NSNotification *)notification
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSIndexPath *indexPath = [self.tracksTVC.fetchedResultsController indexPathForObject:[JXFMAppDelegate jooxPlayer].listTrack];
        [self.tracksTVC.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    });
}

-(void)fetch
{
    [self.listFetcher stop];
    [JXRequest completeFailedRequests:self.list];
    self.list.lastView = [NSDate date];
    
    if ([self.list isPlaylist]) {
        [self fetchPlaylist];
    } else if ([self.list isParty]) {
        [self fetchParty];
    }
}

-(void)fetchPlaylist
{
    [JXRequest fetchPlaylist:[self.list.identifier integerValue] onCompletion:^{
        [self finishFetch];
    }];
}

-(void)fetchParty
{
    [JXRequest fetchParty:[self.list.identifier integerValue] onCompletion:^{
        [self finishFetch];
    }];
}

-(void)finishFetch
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tracksTVC.refreshControl endRefreshing];
        [self.listFetcher start];
    });
}

- (IBAction)dismiss:(id)sender
{
    [self.listFetcher stop];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initScrollView
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop){
        CGRect frame = view.frame;
        frame.origin.x = index * self.scrollView.bounds.size.width;
        view.frame = frame;
    }];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*self.scrollView.subviews.count, self.scrollView.bounds.size.height);
}

-(void)initStyles
{
    self.topBar.layer.shadowRadius = 2;
    self.topBar.layer.shadowOpacity = 0.8;
    self.topBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.topBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBar.bounds].CGPath;
    
    self.bottomBar.layer.shadowRadius = 2;
    self.bottomBar.layer.shadowOpacity = 0.8;
    self.bottomBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.bottomBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bottomBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBar.bounds].CGPath;
    
    for (UIView *view in self.scrollView.subviews) {
        view.layer.shadowRadius = 1;
        view.layer.shadowOpacity = 0.4;
        view.layer.shadowOffset = CGSizeMake(0, 0);
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    }
    
    if ([self.list isParty]) {
        self.nameLabel.selected = [self.list.active boolValue];
    }

}

-(void)initViews
{
    if ([self.list isParty]) {
        [self.listButton setImage:[UIImage imageNamed:@"party-gray.png"] forState:UIControlStateNormal];
        [self.listButton setImage:[UIImage imageNamed:@"party-blue.png"] forState:UIControlStateHighlighted];
        [self.listButton setImage:[UIImage imageNamed:@"party-blue.png"] forState:UIControlStateSelected];
    }
    
    [self.nameLabel setTitle:self.list.name forState:UIControlStateNormal];
    [self showListIcons];
}

- (IBAction)showOptions:(id)sender
{
    [self toggleVideo];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Tracks Segue"]) {
        JooxListTracksVC *vc = segue.destinationViewController;
        vc.list = self.list;
        self.tracksTVC = vc;
    }
    
    if ([segue.identifier isEqualToString:@"Activity Segue"]) {
        self.activityTVC = segue.destinationViewController;
        self.activityTVC.list = self.list;
    }
    
    if ([segue.identifier isEqualToString:@"Users Segue"]) {
        self.usersCVC = segue.destinationViewController;
        self.usersCVC.list = self.list;
    }
    
    if ([segue.identifier isEqualToString:@"Add User Segue"]) {
        AddUserVC *vc = segue.destinationViewController;
        vc.list = self.list;
    }
    
    if ([segue.identifier isEqualToString:@"Add Track Segue"]) {
        AddTrackVC *vc = segue.destinationViewController;
        vc.list = self.list;
    }
    
    if ([segue.identifier isEqualToString:@"Bar Code Segue"]) {
        BarCodeVC *vc = segue.destinationViewController;
        vc.jooxID = ((Party *)self.list).jooxID;
    }
}

-(void)startedDownloading
{
    [self showProgressbar];
}

-(void)finishedDownloading:(BOOL)success
{
    [self hideProgressbar];
}

-(void)updatedProgress:(CGFloat)progress
{
    [self.progressBar setProgress:progress animated:YES];
}

- (IBAction)addUser:(id)sender
{
    if ([self.list isParty]) {
        [self performSegueWithIdentifier:@"Bar Code Segue" sender:self];
    } else if ([self.list isPlaylist]) {
        [self performSegueWithIdentifier:@"Add User Segue" sender:self];
    }
}

- (IBAction)infoButton:(id)sender
{
    [self selectButton:sender];
    [self showOptions];
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-88) animated:YES];
}

- (IBAction)listButton:(id)sender
{
    [self selectButton:sender];
    [self showListIcons];
    [self.scrollView scrollRectToVisible:CGRectMake(self.view.bounds.size.width,
                                                    0,
                                                    self.view.bounds.size.width,
                                                    self.view.bounds.size.height-88)
                                animated:YES];
}

- (IBAction)startParty:(id)sender
{
    if ([self.list isParty]) return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start a Party"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Start Party",nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (IBAction)restartParty:(id)sender
{
    if ([self.list isPlaylist]) return;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to restart this party? All tracks will be set to unplayed and all votes will be cleared. Users already in the party will remain and a new join code will be generated to allow new users to join."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Restart Party"
                                              otherButtonTitles:nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [sheet showInView:self.view];
}

-(void)startPartyWithName:(NSString *)name
{
    [JXRequest createParty:name
              fromPlaylist:[self.list.identifier integerValue]
              onCompletion:^(NSString *partyID){
                  [JXRequest fetchParty:[partyID integerValue] onCompletion:nil];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self dismiss:nil];
                  });
              }];
}

-(void)endParty
{
    [self.loading startAnimating];
    self.endPartyButton.hidden = YES;
    [JXRequest endparty:[self.list.identifier integerValue] onCompletion:^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [[JXFMAppDelegate context] performBlockAndWait:^{
                    self.list.active = nil;
                }];
                [self activeStateChanged];
            } else {
                self.endPartyButton.hidden = NO;
            }
            [self.loading stopAnimating];
        });
    }];
}

-(void)restartParty
{
    [self hideVideo];
    [[JXFMAppDelegate jooxPlayer].player pause];
    [self.loading startAnimating];
    self.restartPartyButton.hidden = YES;
    [JXRequest restartParty:[self.list.identifier integerValue] onCompletion:^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [[JXFMAppDelegate context] performBlockAndWait:^{
                    [(Party *)self.list restart];
                }];
                [self activeStateChanged];
            } else {
                self.restartPartyButton.hidden = NO;
            }
            [self.loading stopAnimating];
            [self listButton:self.listButton];
        });
    }];
}

-(void)activeStateChanged
{
    self.tracksTVC.originalActive = [self.list.active boolValue];
    [self initStyles];
    [self listButton:self.listButton];
    [self.tracksTVC performSelector:@selector(setUpParty)];
    if (![self.list isHost]) [self alertPartyActiveChanged];
}

-(void)alertPartyActiveChanged
{
    if (self.list.active) {
        [Joox alert:[NSString stringWithFormat:@"%@ has restarted this party! All previous tracks remain in the list but lose their votes. Feel free to add new tracks, invite new people, and vote on your favorite songs to hear them play.",self.list.creator.fullName] withTitle:@"Party Restarted"];
    } else {
        [Joox alert:[NSString stringWithFormat:@"The host, %@, has ended the party.\n\nThis party will remain in your JooxLists where you will be able to download or stream any song in the playlist.",self.list.creator.fullName] withTitle:@"Party Ended"];
    }
}

- (IBAction)endParty:(id)sender
{
    if ([self.list isPlaylist]) return;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to end this party?\n\nOnce ended a party cannot be restarted and users will no longer be able to add tracks or join."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"End Party"
                                              otherButtonTitles:nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [sheet showInView:self.view];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    if ([self.list isPlaylist]) {
        [self startPartyWithName:[alertView textFieldAtIndex:0].text];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (self.list.active) {
            [self endParty];
        } else {
            [self restartParty];
        }
    }
}

- (IBAction)peopleButton:(id)sender
{
    [self selectButton:sender];
    [self showPeopleIcons];
    [self.scrollView scrollRectToVisible:CGRectMake(self.view.bounds.size.width*2,
                                                    0,
                                                    self.view.bounds.size.width,
                                                    self.view.bounds.size.height)
                                animated:YES];
}

- (IBAction)sortListByTime:(id)sender
{
    if (!self.timeButton.selected) {
        self.ratingButton.selected = NO;
        self.timeButton.selected = YES;
        [self.tracksTVC.fetchedResultsController.fetchRequest
         setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        [self.tracksTVC animateUpdates];
    }
}
- (IBAction)sortListByRating:(id)sender
{
    if (!self.ratingButton.selected) {
        self.timeButton.selected = NO;
        self.ratingButton.selected = YES;
        [self.tracksTVC.fetchedResultsController.fetchRequest
         setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO],
         [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        [self.tracksTVC animateUpdates];
    }
}
- (IBAction)sortUsersByTime:(id)sender
{
    if (!self.peopleTimeButton.selected) {
        self.alphabetButton.selected = NO;
        self.peopleTimeButton.selected = YES;
        [self.usersCVC.fetchedResultsController.fetchRequest
         setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        [self.usersCVC animateUpdates];
    }
}
- (IBAction)sortUserByName:(id)sender
{
    if (!self.alphabetButton.selected) {
        self.alphabetButton.selected = YES;
        self.peopleTimeButton.selected = NO;
        [self.usersCVC.fetchedResultsController.fetchRequest
         setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user.fullName" ascending:YES selector:@selector(caseInsensitiveCompare:)],
         [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        [self.usersCVC animateUpdates];
    }
}

- (IBAction)toggleAllPartyTracks:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.tracksTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"list = %@",self.list]];
    } else {
        [self.tracksTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"list = %@ AND state != 1",self.list]];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateView];
    [self updateBarView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.x < -80) {
        [self dismiss:nil];
    }
}

-(void)updateView
{
    if (self.scrollView.contentOffset.x == 0) {
        [self selectButton:self.infoButton];
    }
    
    if (self.scrollView.contentOffset.x == self.scrollView.bounds.size.width) {
        [self selectButton:self.listButton];
    }
    
    if (self.scrollView.contentOffset.x == self.scrollView.bounds.size.width*2) {
        [self selectButton:self.peopleButton];
    }
}

-(void)selectButton:(UIButton *)button
{
    [self clearButtons];
    button.selected = YES;
}

-(void)clearButtons
{
    self.infoButton.selected = NO;
    self.listButton.selected = NO;
    self.peopleButton.selected = NO;
}

-(void)updateBarView
{
    CGRect frame = self.barView.frame;
    frame.origin.x = self.scrollView.contentOffset.x * (self.listButton.bounds.size.width / self.view.bounds.size.width);
    self.barView.frame = frame;
}

-(void)showProgressbar
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         CGRect frame = self.bottomBar.frame;
                         frame.origin.y = self.view.bounds.size.height-frame.size.height;
                         self.bottomBar.frame = frame;
                         
                         frame = self.scrollView.frame;
                         frame.size.height -= 10;
                         self.scrollView.frame = frame;
                         
                         self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.bounds.size.height);
                     }];
}

-(void)hideProgressbar
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         CGRect frame = self.bottomBar.frame;
                         frame.origin.y = self.view.bounds.size.height-self.topBar.frame.size.height;
                         self.bottomBar.frame = frame;
                         
                         frame = self.scrollView.frame;
                         frame.size.height += 10;
                         self.scrollView.frame = frame;
                         
                         self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.bounds.size.height);
                     }completion:^(BOOL done){
                         if (done) [self.progressBar setProgress:0];
                     }];
}

-(void)showVideo:(BOOL)animated
{
    void (^animate)() = ^(){
        CGFloat playerHeight = self.playerView.bounds.size.height;
        self.topBar.frame = CGRectMake(0, playerHeight, self.view.bounds.size.width, 44);
        self.scrollView.frame = CGRectMake(0, 44+playerHeight, self.view.bounds.size.width, self.view.bounds.size.height-88-playerHeight);
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*3, self.scrollView.bounds.size.height);
        self.nameLabel.selected = YES;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             animate();
                         }];
    } else {
        animate();
    }
}

- (IBAction)closePlayerView:(id)sender
{
    [self hideVideo];
}


-(void)hideVideo
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.topBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
                         self.scrollView.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-88);
                         self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*3, self.scrollView.bounds.size.height);
                         if (!([self.list isParty] && [self.list.active boolValue])) self.nameLabel.selected = NO;
                     }completion:^(BOOL done){
                         if (done) [[JXFMAppDelegate jooxPlayer] removeFromSuperView];
                     }];
}

-(void)toggleVideo
{
    if (self.topBar.frame.origin.y > 0) {
        [self hideVideo];
    } else {
        if ([[JXFMAppDelegate jooxPlayer] isStopped]) return;
        [self showVideo:YES];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == scrollView.bounds.size.width) {
        [self showListIcons];
    } else if (scrollView.contentOffset.x == scrollView.bounds.size.width * 2) {
        [self showPeopleIcons];
    } else if (scrollView.contentOffset.x == 0) {
        [self showOptions];
    }
}

-(void)showPeopleIcons
{
    [self hideAll:^{
        self.peopleButtonView.hidden = NO;
        self.addUserButton.hidden = !self.list.active;
        self.peopleButtonView.layer.opacity = 1;
        self.addUserButton.layer.opacity = 1;

    }complete:nil];
}

-(void)showListIcons
{
    [self hideAll:^{
        if ([self.list isParty] && self.list.active) {
            self.listButtonView.hidden = YES;
            self.allTracksButton.hidden = NO;
            self.addTrackButton.hidden = NO;
            self.restartPartyButton.hidden = YES;
        } else {
            self.addTrackButton.hidden = [self.list isParty];
            self.restartPartyButton.hidden = !([self.list isParty]);
            self.listButtonView.hidden = NO;
            self.allTracksButton.hidden = YES;
        }
        self.listButtonView.layer.opacity = 1;
        self.addTrackButton.layer.opacity = 1;
        self.allTracksButton.layer.opacity = 1;
        self.restartPartyButton.layer.opacity = 1;
    }complete:nil];
}

-(void)showOptions
{
    [self hideAll:^{
        if ([self.list isPlaylist]) {
            self.startPartyButton.hidden = NO;
            self.startPartyButton.layer.opacity = 1;
        } else {
            if (self.list.active && [self.list isHost]) {
                self.endPartyButton.hidden = NO;
                self.endPartyButton.layer.opacity = 1;
            }
        }
    }complete:nil];
}

-(void)showRestart
{
    [self hideAll:^{
        self.restartPartyButton.hidden = NO;
        self.restartPartyButton.layer.opacity = 1;
    }complete:nil];
}

-(void)hideAll:(DoneCompletionHandler)endAnimation complete:(DoneCompletionHandler)complete
{
    [UIView animateWithDuration:0.15
                     animations:^{
                         self.listButtonView.layer.opacity = 0;
                         self.addTrackButton.layer.opacity = 0;
                         
                         self.peopleButtonView.layer.opacity = 0;
                         self.addUserButton.layer.opacity = 0;
                         
                         self.startPartyButton.layer.opacity = 0;
                         self.endPartyButton.layer.opacity = 0;
                         
                         self.allTracksButton.layer.opacity = 0;
                         self.restartPartyButton.layer.opacity = 0;
                     }completion:^(BOOL done){
                         if (done) {
                             self.listButtonView.hidden = YES;
                             self.addTrackButton.hidden = YES;
                             
                             self.addUserButton.hidden = YES;
                             self.peopleButtonView.hidden = YES;
                             
                             self.startPartyButton.hidden = YES;
                             self.endPartyButton.hidden = YES;
                             
                             self.allTracksButton.hidden = YES;
                             self.restartPartyButton.hidden = YES;
                             [UIView animateWithDuration:0.15 animations:^{
                                 if (endAnimation) endAnimation();
                             }completion:^(BOOL done){
                                 if (complete) complete();
                             }];
                         }
                     }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[JXFMAppDelegate jooxPlayer].player.view removeFromSuperview];
    //[self hideAll:nil complete:nil];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initScrollView];
    [self initStyles];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JooxPlayerListTrackChangedNotification object:[JXFMAppDelegate jooxPlayer]];
}

@end
