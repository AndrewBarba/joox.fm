//
//  JooxJoinCreateViewController.m
//  Jooxbot
//
//  Created by Andrew Barba on 6/3/12.
//  Copyright (c) 2012 WhatsApp. All rights reserved.
//

#import "JooxCreateViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Joox.h"
#import "JXRequest.h"

@interface JooxCreateViewController ()
@property (weak, nonatomic) IBOutlet UIView *createView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIView *createButtonView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *playlistButton;
@property (weak, nonatomic) IBOutlet UIButton *partyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@end

@implementation JooxCreateViewController
@synthesize createView;
@synthesize nameField;
@synthesize createButtonView;
@synthesize backView;
@synthesize detailLabel;
@synthesize playlistButton;
@synthesize partyButton;
@synthesize loading;
@synthesize delegate = _delegate;

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.nameField becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initViews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showView];
    self.nameField.delegate = self;
}

-(void)initViews
{
    self.createView.layer.shadowRadius = 2;
    self.createView.layer.shadowOpacity = 0.8;
    self.createView.layer.shadowOffset = CGSizeMake(1, 1);
    self.createView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.createView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.createView.bounds].CGPath;
    
    self.backView.layer.shadowRadius = 2;
    self.backView.layer.shadowOpacity = 0.8;
    self.backView.layer.shadowOffset = CGSizeMake(4, 1);
    self.backView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.backView.bounds].CGPath;
    
    self.createButtonView.layer.shadowRadius = 2;
    self.createButtonView.layer.shadowOpacity = 0.8;
    self.createButtonView.layer.shadowOffset = CGSizeMake(-4, 1);
    self.createButtonView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.createButtonView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.createButtonView.bounds].CGPath;
    
    CGRect frame = self.createButtonView.frame;
    frame.origin.x = -80;
    self.createButtonView.frame = frame;
    
    frame = self.backView.frame;
    frame.origin.x = self.view.bounds.size.width+20;
    self.backView.frame = frame;
    
    self.detailLabel.layer.opacity = 0;
}

-(void)showView
{
    [self.nameField becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.createButtonView.frame;
        frame.origin.x = 0;
        self.createButtonView.frame = frame;
        
        frame = self.backView.frame;
        frame.origin.x = self.view.bounds.size.width - frame.size.width;
        self.backView.frame = frame;
        
        self.detailLabel.layer.opacity = 1.0;
    }];
}
- (IBAction)party:(UIButton *)sender
{
    sender.selected = YES;
    self.playlistButton.selected = NO;
    self.detailLabel.text = @"start a party and allow guests to add and vote on tracks throughout the night";
}

- (IBAction)playlist:(UIButton *)sender
{
    sender.selected = YES;
    self.partyButton.selected = NO;
    self.detailLabel.text = @"create a playlist to share with friends";
}

- (IBAction)back:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-(void)dismissView:(BOOL)success
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.loading stopAnimating];
//        [UIView animateWithDuration:0.25
//                         animations:^{
//                             [self initViews];
//                             self.detailLabel.layer.opacity = 0;
//                         }completion:^(BOOL done){
//                             [self.delegate userCreatedPlaylist:success];
//                         }];
//    });
//}

- (IBAction)create:(id)sender 
{
    if (![self.nameField.text isEqualToString:@""]) {
        if (self.playlistButton.selected) {
            [self createPlaylist:self.nameField.text];
        } else {
            [self createParty:self.nameField.text];
        }
    }
}

-(void)createPlaylist:(NSString *)name
{
    [self.loading startAnimating];
    [JXRequest createPlaylist:name onCompletion:^(NSUInteger playlistID){
        if (playlistID) {
            [JXRequest fetchPlaylist:playlistID onCompletion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loading stopAnimating];
                [Joox alert:@"We're sorry, please check your network connection and try again" withTitle:@"Error"];
            });
        }
    }];
}

-(void)createParty:(NSString *)name
{
    [self.loading startAnimating];
    [JXRequest createParty:name fromPlaylist:-1 onCompletion:^(NSString *result){
        if (result) {
            [JXRequest fetchParty:[result integerValue] onCompletion:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loading stopAnimating];
                [Joox alert:@"We're sorry, please check your network connection and try again" withTitle:@"Error"];
            });
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.nameField.text isEqualToString:@""]) {
        if (self.playlistButton.selected) {
            [self createPlaylist:self.nameField.text];
        } else {
            [self createParty:self.nameField.text];
        }
        return YES;
    } else {
        return NO;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initViews];
}

@end
