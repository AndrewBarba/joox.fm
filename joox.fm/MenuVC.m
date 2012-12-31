//
//  MenuVC.m
//  joox.fm
//
//  Created by Andrew Barba on 8/16/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "MenuVC.h"
#import "Joox.h"
#import "JXFMAppDelegate.h"
#import "DownloadsVC.h"
#import "InvitesVC.h"

@interface MenuVC ()
// Controllers
@property (nonatomic, strong) DownloadsVC *downloadsVC;
@property (nonatomic, strong) InvitesVC *invitesVC;
@property (nonatomic) BOOL needsReDraw;
// Outlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *invtiesButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadsButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *invitesLabel;
@end

@implementation MenuVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.needsReDraw = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedInviteNotification:) name:JXInviteNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initScrollView];
    [self initStyles];
}

-(void)initStyles
{
    self.bottomBar.layer.shadowRadius = 2;
    self.bottomBar.layer.shadowOpacity = 0.8;
    self.bottomBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.bottomBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bottomBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bottomBar.bounds].CGPath;
    self.invitesLabel.layer.cornerRadius = 9;
    self.invitesLabel.layer.borderWidth = 1;
    self.invitesLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.invitesLabel.backgroundColor = [Joox blueColor];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DownloadVC Segue"]) {
        self.downloadsVC = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:@"Invites Segue"]) {
        self.invitesVC = segue.destinationViewController;
    }
}

-(void)initScrollView
{
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*self.scrollView.subviews.count,
                                             self.scrollView.bounds.size.height);
    self.scrollView.delegate = self;
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop){
        CGRect frame = view.frame;
        frame.origin.x = index * self.scrollView.bounds.size.width;
        view.frame = frame;
    }];
    
    if (self.needsReDraw) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0)];
        self.needsReDraw = NO;
    }
}

-(void)recievedInviteNotification:(NSNotification *)notification
{
    [self updateInvitesLabel:notification.userInfo[@"badge"]];
    [self showInvites:self.invtiesButton];
}

- (IBAction)showInvites:(UIButton *)sender
{
    if (!sender.selected) [self deselectButtons];
    sender.selected = YES;
    CGRect rect = self.scrollView.bounds;
    rect.origin.x = rect.size.width*0;
    [self.scrollView scrollRectToVisible:rect animated:YES];
}

-(void)updateInvitesLabel:(NSNumber *)numOf
{
    NSUInteger invites = [numOf integerValue];
    [UIView animateWithDuration:0.2 animations:^{
        self.invitesLabel.layer.opacity = invites ? 1 : 0;
    }completion:^(BOOL done){
        self.invitesLabel.text = [NSString stringWithFormat:@"%i",invites];
    }];
}

- (IBAction)showDownloads:(UIButton *)sender
{
    if (!sender.selected) {
        [self deselectButtons];
        sender.selected = YES;
        CGRect rect = self.scrollView.bounds;
        rect.origin.x = rect.size.width;
        [self.scrollView scrollRectToVisible:rect animated:YES];
    } else {
        BOOL open = [self.downloadsVC togglePlayerView];
        [self rotateDownloadsButton:open];
    }
}

-(void)rotateDownloadsButton:(BOOL)open
{
    [UIView animateWithDuration:0.3 animations:^{
        self.downloadsButton.transform = CGAffineTransformMakeRotation(degreesToRadians(open?180:0));
    }];
}

- (IBAction)showSettings:(UIButton *)sender
{
    if (!sender.selected) [self deselectButtons];
    sender.selected = YES;
    CGRect rect = self.scrollView.bounds;
    rect.origin.x = rect.size.width*2;
    [self.scrollView scrollRectToVisible:rect animated:YES];
}

-(void)deselectButtons
{
    self.invtiesButton.selected = NO;
    self.downloadsButton.selected = NO;
    self.settingsButton.selected = NO;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

@end
