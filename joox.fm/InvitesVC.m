//
//  InvitesVC.m
//  joox.fm
//
//  Created by Andrew Barba on 8/18/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "InvitesVC.h"
#import "InviteTVC.h"

@interface InvitesVC () <TableViewContentChangedDelegate>
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (nonatomic, strong) InviteTVC *invitesTVC;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@end

@implementation InvitesVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
}

-(void)initStyles
{
    self.topBar.layer.shadowRadius = 2;
    self.topBar.layer.shadowOpacity = 0.8;
    self.topBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.topBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBar.bounds].CGPath;
    
    self.editButton.hidden = ![self.invitesTVC numberOfObjects];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Invites Segue"]) {
        self.invitesTVC = segue.destinationViewController;
        self.invitesTVC.contentChangedDelegate = self;
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
    [self.parentViewController performSelector:@selector(updateInvitesLabel:) withObject:@(numberOfItems)];
}

- (IBAction)edit:(UIButton *)sender
{
    [self setEditing:!sender.selected];
}

-(void)setEditing:(BOOL)editing
{
    self.invitesTVC.editInvites = editing;
    self.editButton.selected = editing;
}

- (IBAction)refreshInvites:(id)sender
{
    self.refreshButton.hidden = YES;
    [self.loadingView startAnimating];
    [JXRequest fetchAllInvites:^(NSUInteger count){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopAnimating];
            self.refreshButton.hidden = NO;
            [UIApplication sharedApplication].applicationIconBadgeNumber = count;
            [self.parentViewController performSelector:@selector(updateInvitesLabel:) withObject:@(count)];
        });
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setEditing:NO];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

@end
