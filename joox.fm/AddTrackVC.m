//
//  AddTrackVC.m
//  joox.fm
//
//  Created by Andrew Barba on 6/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "AddTrackVC.h"

@interface AddTrackVC () {
    BOOL youtubeSearchComplete;
    BOOL soundcloudSearchComplete;
    BOOL groovesharkSearchComplete;
}
@property (nonatomic, strong) TrackResultsController *youTubeResultsController;
@property (nonatomic, strong) TrackResultsController *soundCloudResultsController;
@property (nonatomic, strong) TrackResultsController *grooveSharkResultsController;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIView *barIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *youtubeButton;
@property (weak, nonatomic) IBOutlet UIButton *soundcloudButton;
@property (weak, nonatomic) IBOutlet UIButton *groovesharkButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@end

@implementation AddTrackVC
@synthesize youtubeButton;
@synthesize soundcloudButton;
@synthesize loading;
@synthesize favoritesButton;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.searchTextField.layer.opacity = 0;
    self.searchTextField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
    [self initScrollView];
}

-(void)initStyles
{
    self.topBar.layer.shadowRadius = 5;
    self.topBar.layer.shadowOpacity = 0.8;
    self.topBar.layer.shadowOffset = CGSizeMake(0, -1);
    self.topBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBar.bounds].CGPath;
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchTextField becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.dismissButton.transform = CGAffineTransformMakeRotation(degreesToRadians(45));
        self.searchTextField.layer.opacity = 1;
    }];
}

-(void)search
{
    [self.loading startAnimating];
    NSString *query = self.searchTextField.text;
    if (!query || [query isEqualToString:@""]) return;
    [self.searchTextField resignFirstResponder];
    [self searchYoutube:query];
    [self searchSoundCloud:query];
    //[self searchMediaLibrary:query];
    [self searchGrooveShark:query];
    [self.youTubeResultsController.collectionView scrollRectToVisible:CGRectMake(0, 0, 320, 372) animated:YES];
    [self.soundCloudResultsController.collectionView scrollRectToVisible:CGRectMake(0, 0, 320, 372) animated:YES];
    [self.grooveSharkResultsController.collectionView scrollRectToVisible:CGRectMake(0, 0, 320, 372) animated:YES];
}

-(void)userDidSelectTrack:(NSDictionary *)track withService:(NSString *)service fromCell:(TrackResultsCell *)cell
{
    if ([self.list isParty]) {
        [JXRequest addTrack:track toParty:[self.list.identifier integerValue] withService:service onCompletion:^(BOOL success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self finishedPickingTrack:success];
                [cell.loadingView stopAnimating];
            });
        }];
    } else if ([self.list isPlaylist]) {
        [JXRequest addTrack:track toPlaylist:[self.list.identifier integerValue] withService:service onCompletion:^(BOOL success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self finishedPickingTrack:success];
                [cell.loadingView stopAnimating];
            });
        }];
    }
}

-(void)finishedPickingTrack:(BOOL)success
{
    if (success) {
        [self dismissView:nil];
    } else {
        [Joox alert:@"It looks like this track has already been added to the list. Pick another track or check your network connection and try again." withTitle:@"Already Added"];
    }
}

-(NSString *)idForTrack:(NSDictionary *)track withService:(NSString *)service
{
    if ([service isEqualToString:ServiceYouTube]) {
        return track[@"id"];
    }
    
    if ([service isEqualToString:ServiceSoundCloud]) {
        return track[@"id"];
    }
    
    if ([service isEqualToString:ServiceGrooveShark]) {
        return track[@"SongID"];
    }
    
    return nil;
}

-(void)searchYoutube:(NSString *)query
{
    youtubeSearchComplete = NO;
    self.youTubeResultsController.tracks = [NSArray array];
    [JXRequest performQueryToYouTube:query onCompletion:^(NSMutableArray *array){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.youTubeResultsController.tracks = array;
            youtubeSearchComplete = YES;
            if (soundcloudSearchComplete && youtubeSearchComplete && groovesharkSearchComplete) [self.loading stopAnimating];
        });
    }];
}

-(void)searchSoundCloud:(NSString *)query
{
    soundcloudSearchComplete = NO;
    self.soundCloudResultsController.tracks = [NSArray array];
    [JXRequest performQueryToSoundCloud:query onCompletion:^(NSMutableArray *array){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.soundCloudResultsController.tracks = array;
            soundcloudSearchComplete = YES;
            if (soundcloudSearchComplete && youtubeSearchComplete && groovesharkSearchComplete) [self.loading stopAnimating];
        });
    }];
}

-(void)searchMediaLibrary:(NSString *)query
{
    MPMediaQuery *searchQuery = [MPMediaQuery songsQuery];
    [searchQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:query
                                                                     forProperty:MPMediaItemPropertyTitle
                                                                  comparisonType:MPMediaPredicateComparisonContains]];
    self.grooveSharkResultsController.tracks = [[searchQuery items] mutableCopy];
}

-(void)searchGrooveShark:(NSString *)query
{
    groovesharkSearchComplete = NO;
    self.grooveSharkResultsController.tracks = [NSArray array];
    [JXRequest performQueryToGrooveshark:query onCompletion:^(NSMutableArray *array){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.grooveSharkResultsController.tracks = array;
            groovesharkSearchComplete = YES;
            if (soundcloudSearchComplete && youtubeSearchComplete && groovesharkSearchComplete) [self.loading stopAnimating];
        });
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self search];
    return YES;
}

- (IBAction)dismissView:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.dismissButton.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
            self.searchTextField.layer.opacity = 0;
        } completion:^(BOOL done){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    });
}

- (IBAction)selectYoutube:(UIButton *)sender
{
    [self scrollToXPos:0];
    self.youtubeButton.selected = YES;
    self.soundcloudButton.selected = NO;
    self.groovesharkButton.selected = NO;
}

- (IBAction)selectSoundcloud:(UIButton *)sender
{
    [self scrollToXPos:self.scrollView.bounds.size.width];
    self.soundcloudButton.selected = YES;
    self.youtubeButton.selected = NO;
    self.groovesharkButton.selected = NO;
}

- (IBAction)selectGrooveShark:(UIButton *)sender
{
    [self scrollToXPos:self.scrollView.bounds.size.width*2];
    self.soundcloudButton.selected = NO;
    self.youtubeButton.selected = NO;
    self.groovesharkButton.selected = YES;
}

- (IBAction)selectFavorites:(id)sender
{
    [self scrollToXPos:self.scrollView.bounds.size.width*2];
}

-(void)scrollToXPos:(CGFloat)x
{
    [self.scrollView scrollRectToVisible:CGRectMake(x, 0,
                                                    self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.size.height) animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Track Results YouTube Segue"]) {
        self.youTubeResultsController = segue.destinationViewController;
        self.youTubeResultsController.delegate = self;
        self.youTubeResultsController.service = ServiceYouTube;
    }
    
    if ([segue.identifier isEqualToString:@"Track Results SoundCloud Segue"]) {
        self.soundCloudResultsController = segue.destinationViewController;
        self.soundCloudResultsController.delegate = self;
        self.soundCloudResultsController.service = ServiceSoundCloud;
    }
    
    if ([segue.identifier isEqualToString:@"Track Results GrooveShark Segue"]) {
        self.grooveSharkResultsController = segue.destinationViewController;
        self.grooveSharkResultsController.delegate = self;
        self.grooveSharkResultsController.service = ServiceGrooveShark;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.barIndicatorView.frame;
    frame.origin.x = self.scrollView.contentOffset.x/self.scrollView.subviews.count;
    self.barIndicatorView.frame = frame;
    if (scrollView.contentOffset.x > self.scrollView.bounds.size.width) {
        self.soundcloudButton.selected = NO;
        self.youtubeButton.selected = NO;
        self.groovesharkButton.selected = YES;
    } else if (scrollView.contentOffset.x > self.scrollView.bounds.size.width/2) {
        self.soundcloudButton.selected = YES;
        self.youtubeButton.selected = NO;
        self.groovesharkButton.selected = NO;
    } else {
        self.soundcloudButton.selected = NO;
        self.youtubeButton.selected = YES;
        self.groovesharkButton.selected = NO;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchTextField resignFirstResponder];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
    [self initScrollView];
}

@end
