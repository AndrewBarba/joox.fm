//
//  JXTabBarController.h
//  joox.fm
//
//  Created by Andrew Barba on 12/11/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXTabBarController : UIViewController <UIScrollViewDelegate>
// Interface Objects
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic) NSUInteger selectedIndex;

// Methods
-(void)setSelectedIndex:(NSUInteger)selectedIndex;

// Interface Outlets
@property (nonatomic, weak) IBOutlet UIView *topBarView;
@property (nonatomic, weak) IBOutlet UIView *bottomBarView;
@property (nonatomic, weak) IBOutlet UIView *indicatorView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end
