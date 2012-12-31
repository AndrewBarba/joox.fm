//
//  WelcomeVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "WelcomeVC.h"
#import "Joox.h"

@interface WelcomeVC ()
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *jooxImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *paging;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@end

@implementation WelcomeVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
    [self initScrollView];
}

-(void)initStyles
{
    self.topView.layer.shadowRadius = 2;
    self.topView.layer.shadowOpacity = 0.8;
    self.topView.layer.shadowOffset = CGSizeMake(0, 0);
    self.topView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topView.bounds].CGPath;
    
    self.bottomView.layer.shadowRadius = 2;
    self.bottomView.layer.shadowOpacity = 0.8;
    self.bottomView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bottomView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bottomView.bounds].CGPath;
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
}

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)previousPage:(id)sender
{
    if ((NSInteger)self.scrollView.contentOffset.x % (NSInteger)self.scrollView.bounds.size.width != 0) return;
    if (self.scrollView.contentOffset.x > 0) {
        CGRect frame = CGRectMake(self.scrollView.contentOffset.x-self.scrollView.bounds.size.width,
                                  0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
}

- (IBAction)nextPage:(id)sender
{
    
    if ((NSInteger)self.scrollView.contentOffset.x % (NSInteger)self.scrollView.bounds.size.width != 0) return;
    if (self.scrollView.contentOffset.x < (self.scrollView.subviews.count-1)*self.scrollView.bounds.size.width) {
        CGRect frame = CGRectMake(self.scrollView.contentOffset.x+self.scrollView.bounds.size.width,
                                  0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.x;
    CGFloat width = self.scrollView.bounds.size.width;
    
    if (offset < width - (width/2)) {
        self.paging.currentPage = 0;
    } else if (offset < (width*2) - (width/2)) {
        self.paging.currentPage = 1;
    } else if (offset < (width*3) - (width/2)) {
        self.paging.currentPage = 2;
    } else if (offset < (width*4) - (width/2)) {
        self.paging.currentPage = 3;
    } else if (offset < (width*5) - (width/2)) {
        self.paging.currentPage = 4;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
    [self initScrollView];
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
