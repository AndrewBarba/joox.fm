//
//  LoginController.m
//  joox.fm
//
//  Created by Andrew Barba on 6/27/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "LoginController.h"
#import "JXFMAppDelegate+CoreData.h"
#import "Joox.h"

@interface LoginController ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;
@property (nonatomic, strong) ACAccountType *accountType;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UIImageView *topRightImage;
@property (weak, nonatomic) IBOutlet UIImageView *bottomRightImage;
@property (weak, nonatomic) IBOutlet UIView *animationView;
@end

@implementation LoginController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.topView.layer.opacity = 0;
    self.loginButton.layer.opacity = 0;
    self.detailLabel.layer.opacity = 0;
    self.loginButton.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
}

-(void)initStyles
{
    self.topView.layer.shadowRadius = 2;
    self.topView.layer.shadowOpacity = 0.2;
    self.topView.layer.shadowOffset = CGSizeMake(0, 3);
    self.topView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topView.bounds].CGPath;
    
    self.loginButton.layer.shadowRadius = 2;
    self.loginButton.layer.shadowOpacity = 0.6;
    self.loginButton.layer.shadowOffset = CGSizeMake(2, 2);
    self.loginButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.loginButton.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.loginButton.bounds].CGPath;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animate];
}

-(void)animate
{
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    [UIView animateWithDuration:0.7
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.leftImage.frame = CGRectMake(-width, 0, self.leftImage.bounds.size.width, self.leftImage.bounds.size.height);
                         self.topRightImage.frame = CGRectMake(width, -height, self.topRightImage.bounds.size.width, self.topRightImage.bounds.size.height);
                         self.bottomRightImage.frame = CGRectMake(width, height, self.bottomRightImage.bounds.size.width, self.bottomRightImage.bounds.size.height);
                     }
                     completion:^(BOOL done){
                         [self setUpJoox];
                         self.leftImage = nil;
                         self.topRightImage = nil;
                         self.bottomRightImage = nil;
                     }];
}

-(void)setUpJoox
{
    [JXFMAppDelegate useDocument:^{
        if ([Joox isFirstRun]) {
            [[JXFMAppDelegate appDelegate] resetDocument:^{
                [Joox setUserInfo:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"About Segue" sender:self];
                });
            }];
        } else {
            if ([Joox isUserValid]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupFacebook:NO];
                    [JXRequest fetchEverything:nil];
                    [Joox initViewController:@"Joox View Controller" inNavigationController:self.navigationController];
                });
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.animationView) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.topView.layer.opacity = 1;
                    self.loginButton.layer.opacity = 1;
                    self.detailLabel.layer.opacity = 1;
                    self.loginButton.enabled = YES;
                    self.animationView.layer.opacity = 0;
                }completion:^(BOOL done){
                    self.animationView = nil;
                }];
            }
        });
    }];
}

-(void)setupFacebook:(BOOL)new
{
    if (new) {
        self.loginButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2 animations:^{self.loginButton.layer.opacity=0.4;}];
        [self.loading startAnimating];
    }
    
    [[JXFMAppDelegate appDelegate] openFBSessionNew:new onComplete:^(NSString *token){
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"TOKEN: %@",token?@"RECIEVED":@"FALSE");
            if (new) [self loginFacebook:token];
        });
    }];
}

-(void)loginFacebook:(NSString *)token
{
    if (token) {
        [self loginToJooxFM:token];
    } else {
        [self loginFailed];
    }
}

-(void)attemptToRenewFacebookCredentials
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailLabel.text = @"renewing facebook credentials";
    });
    [[JXFMAppDelegate appDelegate] renewFacebookCredentials:^(BOOL success){
        if (success) {
            [self setupFacebook:NO];
        } else {
            [self loginFailed];
        }
    }];
}

-(void)loginToJooxFM:(NSString *)token
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailLabel.text = @"logging in to joox.fm";
    });
    [JXRequest addUserWithToken:token onCompletion:^(NSDictionary *userDict){
        if (userDict) {
            [Joox setUserInfo:userDict];
            [self loginSuccess];
        } else {
            [self resetLogin];
        }
    }];
}

-(void)loginFailed
{
    [self resetLogin];
    dispatch_async(dispatch_get_main_queue(), ^{
        //[Joox alertFacebookDenied];
    });
}

-(void)loginSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailLabel.text = @"syncing data";
    });
    [JXRequest fetchEverything:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"Home Segue" sender:self];
            [self resetLogin];
        });
    }];
}

-(void)resetLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailLabel.text = @"please login to joox.fm using your facebook account";
        [self.loading stopAnimating];
        self.loginButton.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.2 animations:^{self.loginButton.layer.opacity=1;}];
    });
}

- (IBAction)login:(UIButton *)sender
{
    [self setupFacebook:YES];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([Joox isiPad]) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

@end
