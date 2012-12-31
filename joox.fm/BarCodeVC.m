//
//  BarCodeVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/16/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "BarCodeVC.h"
#import "JXRequest.h"
#import "Joox.h"
#import "UIImageView+WebCache.h"

@interface BarCodeVC ()
@property (weak, nonatomic) IBOutlet UILabel *jooxIDLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@end

@implementation BarCodeVC
@synthesize topView = _topView;
@synthesize loading = _loading;
@synthesize dismissButton = _dismissButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.jooxIDLabel.text = self.jooxID;
    [self initQrCode];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        self.dismissButton.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
        self.jooxIDLabel.layer.opacity = 1;
    }];
}

-(void)initStyles
{
    self.topView.layer.shadowRadius = 2;
    self.topView.layer.shadowOpacity = 0.8;
    self.topView.layer.shadowOffset = CGSizeMake(0, 0);
    self.topView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topView.bounds].CGPath;
    
    self.containerView.layer.shadowRadius = 2;
    self.containerView.layer.shadowOpacity = 0.8;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 0);
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
    
    self.dismissButton.transform = CGAffineTransformMakeRotation(degreesToRadians(45));
    self.jooxIDLabel.layer.opacity = 0;
}

-(void)initQrCode
{
    self.qrCodeImageView.layer.opacity = 0;
    [self.loading startAnimating];
    [self.qrCodeImageView setImageWithURL:[Joox generateQRURL:self.jooxID]
                                  success:^(UIImage *image){
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.loading stopAnimating];
                                          [UIView animateWithDuration:0.3 animations:^{self.qrCodeImageView.layer.opacity = 1;}];
                                      });
                                  }
                                  failure:^(NSError *error){
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.loading stopAnimating];
                                          [UIView animateWithDuration:0.3 animations:^{self.qrCodeImageView.layer.opacity = 1;}];
                                      });
                                  }];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

- (IBAction)close:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.dismissButton.transform = CGAffineTransformMakeRotation(degreesToRadians(45));
        self.jooxIDLabel.layer.opacity = 0;
    }completion:^(BOOL done){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


@end
