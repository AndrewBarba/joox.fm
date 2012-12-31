//
//  HomeVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/18/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "HomeVC.h"
#import "JXFMAppDelegate+CoreData.h"
#import "JXRequest.h"
#import "FeedTVC.h"
#import "JooxListsTVC.h"
#import "ContainerVC.h"

@interface HomeVC () <TableViewContentChangedDelegate>
// Controllers
@property (strong, nonatomic) FeedTVC *feedTVC;
@property (strong, nonatomic) JooxListsTVC *listsTVC;

// Outlets
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *activityButton;
@property (weak, nonatomic) IBOutlet UIButton *jooxListsButton;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UIView *activityButtonView;
@property (weak, nonatomic) IBOutlet UIView *listButtonView;
@property (weak, nonatomic) IBOutlet UIButton *playlistsButton;
@property (weak, nonatomic) IBOutlet UIButton *partiesButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *trackButton;
@property (weak, nonatomic) IBOutlet UIButton *voteButton;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (weak, nonatomic) IBOutlet UIView *feedView;
@property (weak, nonatomic) IBOutlet UIView *listsView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *jooxButton;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *gestureView;
@end

@implementation HomeVC
@synthesize playerView = _playerView;
@synthesize mainView = _mainView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLayout];
    [[JXFMAppDelegate appDelegate] setupFacebook:nil];
    [JXFMAppDelegate registerForPush];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
    [self initScrollView];
//    [self showAll];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showView];
}

-(void)initLayout
{
    CGRect frame = self.topBar.frame;
    frame.origin.y -= frame.size.height;
    self.topBar.frame = frame;
    
    frame = self.bottomBar.frame;
    frame.origin.y += frame.size.height;
    self.bottomBar.frame = frame;
    
    self.scrollView.layer.opacity = 0;
}

-(void)showView
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect frame = self.topBar.frame;
                         frame.origin.y = 0;
                         self.topBar.frame = frame;
                         
                         frame = self.bottomBar.frame;
                         frame.origin.y = self.mainView.bounds.size.height - frame.size.height;
                         self.bottomBar.frame = frame;
                     }completion:^(BOOL done){
                         [UIView animateWithDuration:0.3 animations:^{self.scrollView.layer.opacity=1;}];
                     }];
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
    self.bottomBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bottomBar.bounds].CGPath;
    
    self.feedView.layer.shadowRadius = 1;
    self.feedView.layer.shadowOpacity = 0.6;
    self.feedView.layer.shadowOffset = CGSizeMake(-0.5, 0);
    self.feedView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.feedView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.feedView.bounds].CGPath;
    
    self.listsView.layer.shadowRadius = 1;
    self.listsView.layer.shadowOpacity = 0.6;
    self.listsView.layer.shadowOffset = CGSizeMake(0.5, 0);
    self.listsView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.listsView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.listsView.bounds].CGPath;
}

-(void)initScrollView
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop){
        CGRect frame = view.frame;
        frame.origin.x = index * self.scrollView.bounds.size.width;
        view.frame = frame;
    }];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*self.scrollView.subviews.count,
                                             self.scrollView.bounds.size.height);
}

-(void)fetch
{
    [self.feedTVC.refreshControl beginRefreshing];
    [self.listsTVC.refreshControl beginRefreshing];
    [JXRequest fetchJooxLists:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.feedTVC.refreshControl endRefreshing];
            [self.listsTVC.refreshControl endRefreshing];
        });
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Activity Segue"]) {
        self.feedTVC = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:@"Lists Segue"]) {
        self.listsTVC = segue.destinationViewController;
        self.listsTVC.contentChangedDelegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"Join Segue"]) {
        JooxJoinViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"Create Segue"]) {
        JooxCreateViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

-(void)contentDidChange:(NSUInteger)numberOfItems
{
    if (numberOfItems == 0) [self setEditing:NO];
}

- (IBAction)refreshLists:(id)sender
{
    [self fetch];
}


- (IBAction)showActivity:(UIButton *)sender
{
    self.activityButton.selected = YES;
    self.jooxListsButton.selected = NO;
    [self showActivityIcons];
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.size.height) animated:YES];
}

- (IBAction)showLists:(UIButton *)sender
{
    self.activityButton.selected = NO;
    self.jooxListsButton.selected = YES;
    [self showListIcons];
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.bounds.size.width, 0,
                                                    self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
}

-(void)showAll
{
    [self.feedTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"type = type"]];
    [self setRequestWithEntity:@"JooxList"];
    
    self.trackButton.selected = NO;
    self.voteButton.selected = NO;
    self.userButton.selected = NO;
    
    self.partiesButton.selected = NO;
    self.playlistsButton.selected = NO;
}

- (IBAction)showTracks:(UIButton *)sender
{
    if (!sender.selected) {
        [self.feedTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"type = 'track'"]];
    } else {
        [self.feedTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"type = type"]];
    }
    
    self.trackButton.selected = !self.trackButton.selected;
    self.voteButton.selected = NO;
    self.userButton.selected = NO;
}

- (IBAction)showVotes:(UIButton *)sender
{
    if (!sender.selected) {
        [self.feedTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"type = 'vote'"]];
    } else {
        [self.feedTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"type = type"]];
    }
    
    self.trackButton.selected = NO;
    self.voteButton.selected = !self.voteButton.selected;
    self.userButton.selected = NO;
}

- (IBAction)showJoins:(UIButton *)sender
{
    if (!sender.selected) {
        [self.feedTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"type = 'user'"]];
    } else {
        [self.feedTVC changeRequestPredicate:[NSPredicate predicateWithFormat:@"type = type"]];
    }
    
    self.trackButton.selected = NO;
    self.voteButton.selected = NO;
    self.userButton.selected = !self.userButton.selected;
}

- (IBAction)showPlaylists:(UIButton *)sender
{
    self.partiesButton.selected = NO;
    self.playlistsButton.selected = !self.playlistsButton.selected;
    [self setRequestWithEntity:self.playlistsButton.selected?@"Playlist":@"JooxList"];
}

- (IBAction)showParties:(UIButton *)sender
{
    self.partiesButton.selected = !self.partiesButton.selected;
    self.playlistsButton.selected = NO;
    [self setRequestWithEntity:self.partiesButton.selected?@"Party":@"JooxList"];
}

-(void)setRequestWithEntity:(NSString *)entity
{
    [self.listsTVC changeRequestEntity:entity];
}

- (IBAction)editLists:(UIButton *)sender
{
    [self setEditing:!sender.selected];
}

-(void)setEditing:(BOOL)editing
{
    self.editButton.selected = editing;
    [self.listsTVC setEditing:editing animated:YES];
}

- (IBAction)addList:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"create a playlist, start a party, or join a party"
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Create",@"Join",nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"Create Segue" sender:self];
    } else if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"Join Segue" sender:self];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.barView.frame;
    frame.origin.x = scrollView.contentOffset.x * (self.activityButton.bounds.size.width / self.view.bounds.size.width);
    self.barView.frame = frame;
    
    if (scrollView.contentOffset.x > scrollView.bounds.size.width / 2) {
        //self.listButtonView.hidden = NO;
        self.jooxListsButton.selected = YES;
        //self.activityButtonView.hidden = YES;
        self.activityButton.selected = NO;
    } else {
        //self.listButtonView.hidden = YES;
        self.jooxListsButton.selected = NO;
        //self.activityButtonView.hidden = NO;
        self.activityButton.selected = YES;
    }    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.x < -80) {
        [self toggleView:nil];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > scrollView.bounds.size.width / 2) {
        [self showListIcons];
    } else {
        [self showActivityIcons];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > scrollView.bounds.size.width / 2) {
        [self showListIcons];
    } else {
        [self showActivityIcons];
    }
}

-(void)userCreatedPlaylist:(BOOL)success
{
    if (success) {
        [self showLists:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)userJoinedJooxList:(BOOL)success
{
    if (success) {
        [self showLists:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)showActivityIcons
{
    [UIView animateWithDuration:0.15
                     animations:^{
                         self.listButtonView.layer.opacity = 0;
                     }completion:^(BOOL done){
                         if (done) {
                             self.activityButtonView.hidden = NO;
                             self.listButtonView.hidden = YES;
                             [UIView animateWithDuration:0.15 animations:^{
                                 self.activityButtonView.layer.opacity = 1;
                             }];
                         }
                     }];
}

-(void)showListIcons
{
    [UIView animateWithDuration:0.15
                     animations:^{
                         self.activityButtonView.layer.opacity = 0;
                     }completion:^(BOOL done){
                         if (done) {
                             self.listButtonView.hidden = NO;
                             self.activityButtonView.hidden = YES;
                             [UIView animateWithDuration:0.15 animations:^{
                                 self.listButtonView.layer.opacity = 1;
                             }];
                         }
                     }];
}

-(void)showPlayerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.bounds;
        frame.size.height -= self.playerView.bounds.size.height;
        frame.origin.y = self.playerView.bounds.size.height;
        self.mainView.frame = frame;
        [self initScrollView];
    }];
}

-(void)hidePlayerView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.mainView.frame = self.view.bounds;
        [self initScrollView];
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[JXFMAppDelegate jooxPlayer] removeFromSuperView];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
    [self initScrollView];
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender
{
    ContainerVC *vc = (ContainerVC *)self.parentViewController;
    [vc userDidPan:sender toggleView:self.gestureView];
}

- (IBAction)toggleView:(id)sender
{
    ContainerVC *vc = (ContainerVC *)self.parentViewController;
    [vc toggleMenu:self.gestureView];
}

- (IBAction)tapView:(id)sender
{
    ContainerVC *vc = (ContainerVC *)self.parentViewController;
    [vc toggleMenu:self.gestureView];
}

@end


















