//
//  DownloadsVC.m
//  joox.fm
//
//  Created by Andrew Barba on 8/18/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "DownloadsVC.h"
#import "DownloadsTVC.h"
#import "PlayerVC.h"

@interface DownloadsVC () <TableViewContentChangedDelegate>
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic, strong) DownloadsTVC *downloadsTVC;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) PlayerVC *playerVC;
@end

@implementation DownloadsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.searchBar.delegate = self;
    [self.searchBar addTarget:self action:@selector(searchBarDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void)searchBarDidChange:(UITextField *)textField
{
    [self.downloadsTVC search:textField.text];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchBar resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self closePlayerView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
    [JXFMAppDelegate jooxPlayer].delegate = self.playerVC;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)initStyles
{
    self.topBar.layer.shadowRadius = 2;
    self.topBar.layer.shadowOpacity = 0.8;
    self.topBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.topBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBar.bounds].CGPath;
    
    self.editButton.hidden = ![self.downloadsTVC numberOfObjects];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Downloads Segue"]) {
        self.downloadsTVC = segue.destinationViewController;
        self.downloadsTVC.contentChangedDelegate = self;
    } else if ([segue.identifier isEqualToString:@"PlayerVC Segue"]) {
        self.playerVC = segue.destinationViewController;
    }
}

-(void)contentDidChange:(NSUInteger)numberOfItems
{
    if (numberOfItems >= 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.editButton.layer.opacity = 1;
            self.editButton.hidden = NO;
        }];
    } else {
        [self setEditing:NO];
        [UIView animateWithDuration:0.2 animations:^{
            self.editButton.layer.opacity = 0;
            self.editButton.hidden = YES;
        }];
    }
}

-(void)setEditing:(BOOL)editing
{
    [self.downloadsTVC setEditing:editing animated:YES];
    self.editButton.selected = editing;
}

- (IBAction)edit:(UIButton *)sender
{
    [self setEditing:!self.downloadsTVC.tableView.isEditing];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

-(BOOL)togglePlayerView
{
    if (self.topView.frame.origin.y == 0) {
        [self openPlayerView];
        return YES;
    } else {
        [self closePlayerView];
        return NO;
    }
}

-(void)openPlayerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.topView.frame;
        frame.origin.y = self.playerView.bounds.size.height;
        frame.size.height = self.view.bounds.size.height - self.playerView.bounds.size.height;
        self.topView.frame = frame;
    }];
    [self.parentViewController performSelector:@selector(rotateDownloadsButton:) withObject:@(YES)];
}

-(void)closePlayerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.topView.frame;
        frame.origin.y = 0;
        frame.size.height = self.view.bounds.size.height;
        self.topView.frame = frame;
    }completion:^(BOOL finished){
//        [[JXFMAppDelegate jooxPlayer] removeFromSuperView];
    }];
    [self.parentViewController performSelector:@selector(rotateDownloadsButton:) withObject:nil];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

@end
