//
//  ContainerVC.m
//  joox.fm
//
//  Created by Andrew Barba on 8/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ContainerVC.h"
#import "Joox.h"

#define OPEN 270
#define TILT 10
#define OPEN_TOP 20
#define CLOSED 0
#define OPEN_THRESHOLD 160

@interface ContainerVC ()
@property (nonatomic) CGFloat lastX;
@end

@implementation ContainerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initStyles];
	self.lastX = 0;
    
}

-(void)initStyles
{
    self.topView.layer.shadowRadius = 5;
    self.topView.layer.shadowOpacity = 1.0;
    self.topView.layer.shadowOffset = CGSizeMake(0, 0);
    self.topView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topView.bounds].CGPath;
}

-(void)userDidPan:(UIPanGestureRecognizer *)pan toggleView:(UIView *)view
{
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [pan translationInView:self.view];
        CGRect frame = self.topView.frame;
        frame.origin.x = self.lastX + point.x;
        if (frame.origin.x > OPEN) frame.origin.x = OPEN;
        if (frame.origin.x < CLOSED) frame.origin.x = CLOSED;
        self.topView.frame = frame;
//        self.topView.transform = CGAffineTransformMakeRotation(degreesToRadians(frame.origin.x/30));
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (self.topView.frame.origin.x >= OPEN_THRESHOLD) {
            [self openMenu:(self.lastX==0?0.1:0.3) withView:view];
        } else {
            [self closeMenu:(self.lastX==0?0.3:0.1) withView:view];
        }
    }
    
}

-(void)closeMenu:(CGFloat)speed withView:(UIView *)view
{
    [UIView animateWithDuration:speed animations:^{
//        self.topView.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
        CGRect frame = self.topView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        self.topView.frame = frame;
        self.lastX = 0;
        view.userInteractionEnabled = NO;
    }];
}

-(void)openMenu:(CGFloat)speed withView:(UIView *)view
{
    [UIView animateWithDuration:speed animations:^{
        CGRect frame = self.topView.frame;
        frame.origin.x = OPEN;
//        frame.origin.y = OPEN_TOP;
        self.topView.frame = frame;
//        self.topView.transform = CGAffineTransformMakeRotation(degreesToRadians(TILT));
        self.lastX = OPEN;
        view.userInteractionEnabled = YES;
    }];
}

-(void)toggleMenu:(UIView *)view
{
    if (self.topView.frame.origin.x >= OPEN_THRESHOLD) {
        [self closeMenu:0.3 withView:view];
    } else {
        [self openMenu:0.3 withView:view];
    }
}

-(void)invtieNotificationRecieved
{
    [self openMenu:0 withView:nil];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

@end
