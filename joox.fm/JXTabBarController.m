//
//  JXTabBarController.m
//  joox.fm
//
//  Created by Andrew Barba on 12/11/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JXTabBarController.h"
#import "AB.h"

@interface JXTabBarController ()
@property (weak, nonatomic) IBOutlet UILabel *invitesLabel;
@end

#define WIDTH  self.scrollView.bounds.size.width
#define HEIGHT self.scrollView.bounds.size.height

@implementation JXTabBarController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.viewControllers = [NSMutableArray array];
        self.buttons = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initScrollView];
    [self initStyles];
	[self initButtonArrayAndViewControllers];
}

-(void)initStyles
{
    self.topBarView.layer.shadowRadius = 1.5;
    self.topBarView.layer.shadowOpacity = 0.8;
    self.topBarView.layer.shadowOffset = CGSizeMake(0, 0);
    self.topBarView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topBarView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBarView.bounds].CGPath;
    
    self.bottomBarView.layer.shadowRadius = 1.5;
    self.bottomBarView.layer.shadowOpacity = 0.8;
    self.bottomBarView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bottomBarView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bottomBarView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bottomBarView.bounds].CGPath;
    
    self.invitesLabel.layer.opacity = 0;
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

-(void)initButtonArrayAndViewControllers
{
    [self.topBarView.subviews enumerateObjectsUsingBlock:^(id view, NSUInteger index, BOOL *stop){
        if ([[view class] isSubclassOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttons addObject:button];
        }
    }];
        
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id view, NSUInteger index, BOOL *stop){
        if ([[view class] isSubclassOfClass:[UIView class]]) {
            [self.viewControllers addObject:view];
        }
    }];
    
    self.scrollView.contentSize = CGSizeMake(WIDTH*self.viewControllers.count, HEIGHT);
    [self setSelectedIndex:(self.viewControllers.count/2) withAnimation:NO];
}

-(void)buttonPressed:(UIButton *)button
{
    [self setSelectedIndex:[self.buttons indexOfObject:button] withAnimation:YES];
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex) {
        UIButton *selected = self.buttons[_selectedIndex];
        [selected setSelected:NO];
        
        UIButton *newSelected = self.buttons[selectedIndex];
        [newSelected setSelected:YES];
        
        _selectedIndex = selectedIndex;
    }
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex withAnimation:(BOOL)animate
{
    CGFloat offset = WIDTH * selectedIndex;
    [self.scrollView scrollRectToVisible:CGRectMake(offset, 0, WIDTH, HEIGHT) animated:animate];
    [self setSelectedIndex:selectedIndex];
}

-(void)updateIndicatorViewAndIndex
{
    CGFloat offset = self.scrollView.contentOffset.x / self.buttons.count;
    [self.indicatorView moveToPoint:CGPointMake(offset, self.indicatorView.frame.origin.y)];
    if (self.scrollView.isDragging) [self setSelectedIndex:floorf(self.scrollView.contentOffset.x/WIDTH)];
}

-(void)updateInvitesLabel:(NSNumber *)numberOfInvites
{
    NSUInteger invites = [numberOfInvites integerValue];
    [UIView animateWithDuration:0.2 animations:^{
        self.invitesLabel.layer.opacity = invites ? 1 : 0;
    }completion:^(BOOL done){
        self.invitesLabel.text = [NSString stringWithFormat:@"%i",invites];
    }];
}

// SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateIndicatorViewAndIndex];
}


@end
